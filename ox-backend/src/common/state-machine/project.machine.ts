import { createMachine } from 'xstate';

/**
 * Máquina de estados do projeto (XState v5).
 *
 * O admin cria a obra após a visita presencial, então não há etapa de validação:
 *   draft → matched → contract_signed → active_escrow → in_execution → closing → closed
 *
 * Eventos:
 *  - READY  (admin): publica um rascunho — `draft → matched`.
 *  - PAY    (cliente): confirma pagamento/escrow — `contract_signed → active_escrow`.
 *  - START  (worker/admin): inicia execução — `active_escrow → in_execution`.
 *  - COMPLETE (worker/admin): solicita encerramento — `in_execution → closing`.
 *  - CONFIRM (cliente/admin): confirma encerramento — `closing → closed`.
 *
 * `matched → contract_signed` acontece automaticamente em ContractsService quando
 * o admin atribui um worker via /matching/:id/assign — não há evento explícito.
 *
 * Estados finais: closed, rejected (rejected é reservado para cancelamentos
 * administrativos futuros — sem transição de entrada nesta máquina).
 */
export const projectMachine = createMachine({
  id: 'project',
  initial: 'draft',
  states: {
    draft: {
      on: { READY: 'matched' },
    },
    matched: {},
    contract_signed: {
      on: { PAY: 'active_escrow' },
    },
    active_escrow: {
      on: { START: 'in_execution' },
    },
    in_execution: {
      on: { COMPLETE: 'closing' },
    },
    closing: {
      on: { CONFIRM: 'closed' },
    },
    closed: {
      type: 'final',
    },
    rejected: {
      type: 'final',
    },
  },
});

/**
 * Mapa de transições derivado da definição da máquina.
 * Usado para validação sem depender do runtime do XState.
 */
function buildTransitionMap(): Map<string, Map<string, string>> {
  const transitions = new Map<string, Map<string, string>>();

  for (const [stateName, stateDef] of Object.entries(projectMachine.config.states ?? {})) {
    const events = new Map<string, string>();
    if (stateDef.on) {
      for (const [eventName, target] of Object.entries(stateDef.on)) {
        events.set(eventName, target as string);
      }
    }
    transitions.set(stateName, events);
  }

  return transitions;
}

const transitionMap = buildTransitionMap();

/**
 * Verifica se uma transição de estado é válida.
 * Retorna o novo estado se for válido, ou null se for inválida.
 */
export function getNextStatus(currentStatus: string, event: string): string | null {
  const stateTransitions = transitionMap.get(currentStatus);
  if (!stateTransitions) return null;

  return stateTransitions.get(event) ?? null;
}

/**
 * Retorna a lista de eventos (transições) disponíveis para um determinado status.
 */
export function getAvailableEvents(currentStatus: string): string[] {
  const stateTransitions = transitionMap.get(currentStatus);
  if (!stateTransitions) return [];

  return Array.from(stateTransitions.keys());
}

/**
 * Mapeia eventos para nomes legíveis (uso em logs/UI)
 */
export const EVENT_LABELS: Record<string, string> = {
  READY: 'Publicar obra (pronta para matching)',
  PAY: 'Confirmar pagamento (escrow)',
  START: 'Iniciar execução',
  COMPLETE: 'Solicitar encerramento',
  CONFIRM: 'Confirmar encerramento',
};
