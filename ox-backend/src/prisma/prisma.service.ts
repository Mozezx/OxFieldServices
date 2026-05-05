import { Injectable, OnModuleDestroy, OnModuleInit } from '@nestjs/common';
import { Prisma, PrismaClient } from '@prisma/client';

const TRANSIENT_PRISMA_CODES = new Set([
  'P1017', // Server has closed the connection
  'P1001', // Can't reach database server
  'P1008', // Operations timed out
]);

function sleep(ms: number) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function isTransientPrismaError(error: unknown): boolean {
  return (
    error instanceof Prisma.PrismaClientKnownRequestError &&
    TRANSIENT_PRISMA_CODES.has(error.code)
  );
}

async function withTransientRetry<T>(
  run: () => Promise<T>,
  maxAttempts = 3,
): Promise<T> {
  let lastError: unknown;
  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      return await run();
    } catch (e) {
      lastError = e;
      if (!isTransientPrismaError(e) || attempt === maxAttempts) {
        throw e;
      }
      await sleep(50 * attempt);
    }
  }
  throw lastError;
}

function createExtendedClient() {
  return new PrismaClient().$extends({
    query: {
      async $allOperations({ args, query }) {
        return withTransientRetry(() => query(args));
      },
    },
  });
}

export type ExtendedPrismaClient = ReturnType<typeof createExtendedClient>;

/** Merged with class so inject sites keep full PrismaClient-like typings. */
export interface PrismaService extends ExtendedPrismaClient {}

/**
 * PrismaClient methods must run with the real client as `this` (engine lives there).
 * Object.assign(service, client) breaks $connect and any method that uses `this` on the root client.
 */
@Injectable()
export class PrismaService implements OnModuleInit, OnModuleDestroy {
  private readonly client: ExtendedPrismaClient;

  constructor() {
    this.client = createExtendedClient();
    return new Proxy(this, {
      get: (target, prop, receiver) => {
        if (prop in target) {
          return Reflect.get(target, prop, receiver);
        }
        const value = Reflect.get(
          target.client,
          prop,
          target.client,
        ) as unknown;
        if (typeof value === 'function') {
          return value.bind(target.client);
        }
        return value;
      },
    }) as this;
  }

  async onModuleInit() {
    await this.client.$connect();
  }

  async onModuleDestroy() {
    await this.client.$disconnect();
  }
}
