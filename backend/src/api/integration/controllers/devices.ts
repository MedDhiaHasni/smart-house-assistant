import { runtimeStore } from '../../../services/rule-engine/runtime-store';
import { createManualCommand, jsonRecord, record, requiredString } from './controller-utils';

export default {
  async deviceCommand(ctx: any) {
    const body = record(ctx.request.body, 'Device command request');
    const command = createManualCommand(
      requiredString(ctx.params.id, 'device id'),
      requiredString(body['command'], 'command'),
      jsonRecord(body['parameters'] ?? {}, 'parameters'),
    );
    ctx.body = { data: command };
  },

  async emergencyAllOff(ctx: any) {
    const commands = Object.keys(runtimeStore.deviceStates).map((deviceId) =>
      createManualCommand(deviceId, 'power_off', {}),
    );
    ctx.body = { data: { commands, queued: commands.length } };
  },
};
