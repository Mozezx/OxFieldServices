FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./
COPY prisma ./prisma/

RUN npm ci

RUN npx prisma generate

COPY . .
RUN npm run build

FROM node:20-alpine AS production

RUN addgroup -g 1001 -S oxgroup && \
    adduser -S oxuser -u 1001 -G oxgroup

WORKDIR /app

COPY --from=builder --chown=oxuser:oxgroup /app/node_modules ./node_modules
COPY --from=builder --chown=oxuser:oxgroup /app/dist ./dist
COPY --from=builder --chown=oxuser:oxgroup /app/prisma ./prisma
COPY --from=builder --chown=oxuser:oxgroup /app/package*.json ./
COPY --from=builder --chown=oxuser:oxgroup /app/scripts ./scripts

RUN chmod +x scripts/start.sh scripts/healthcheck.sh

USER oxuser

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD sh scripts/healthcheck.sh

CMD ["sh", "scripts/start.sh"]
