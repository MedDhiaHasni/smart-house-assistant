export type JsonValue =
  | string
  | number
  | boolean
  | null
  | JsonValue[]
  | { [key: string]: JsonValue };

export type ConditionOperator =
  | 'equals'
  | 'notEquals'
  | 'greaterThan'
  | 'lessThan'
  | 'isTrue'
  | 'isFalse';

export interface Condition {
  variable: string;
  operator: ConditionOperator;
  expected?: JsonValue;
}

export interface RuleAction {
  deviceId: string;
  command: string;
  parameters: Record<string, JsonValue>;
  maxRetries?: number;
  fallback?: {
    command: string;
    parameters: Record<string, JsonValue>;
  };
}

export interface RuleDefinition {
  id: string;
  name: string;
  enabled: boolean;
  trigger: { eventType: string };
  conditions: Condition[];
  exceptions: Condition[];
  actions: RuleAction[];
  priority: number;
}

export interface SimulatorEvent {
  id: string;
  eventType: string;
  payload: Record<string, JsonValue>;
  source: string;
  occurredAt: string;
}

export interface TraceStep {
  at: string;
  stage: string;
  message: string;
  actual?: JsonValue;
  expected?: JsonValue;
  ruleId?: string;
  commandId?: string;
}

export type ExecutionStatus =
  | 'evaluating'
  | 'pending'
  | 'succeeded'
  | 'failed'
  | 'skipped';

export interface Execution {
  id: string;
  status: ExecutionStatus;
  event: SimulatorEvent;
  simulatedAt: string;
  trace: TraceStep[];
  commandIds: string[];
}

export type CommandStatus = 'queued' | 'sent' | 'succeeded' | 'failed';

export interface DeviceCommand {
  id: string;
  deviceId: string;
  command: string;
  parameters: Record<string, JsonValue>;
  status: CommandStatus;
  attempts: number;
  maxRetries: number;
  fallback?: RuleAction['fallback'];
  executionId: string;
  ruleId: string;
  priority: number;
  error?: string;
}

export interface OverrideRecord {
  id: string;
  deviceId: string;
  value: Record<string, JsonValue>;
  startsAt: string;
  expiresAt: string;
  active: boolean;
}
