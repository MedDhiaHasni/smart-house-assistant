require('dotenv').config({ path: require('node:path').join(__dirname, '..', '.env') });

const jwt = require('jsonwebtoken');
const { io } = require('socket.io-client');

const apiUrl = process.env.SMART_HOME_API_URL || 'http://localhost:1337/api';
const socketUrl = new URL(apiUrl);
socketUrl.pathname = socketUrl.pathname.replace(/\/api\/?$/, '');
const deviceId = 'bedroom-heater';

async function request(path, method = 'GET', body) {
  const response = await fetch(`${apiUrl}${path}`, {
    method,
    headers: body === undefined ? {} : { 'content-type': 'application/json' },
    body: body === undefined ? undefined : JSON.stringify(body),
  });
  const payload = await response.json();
  if (!response.ok) {
    throw new Error(`${method} ${path} failed (${response.status}): ${JSON.stringify(payload)}`);
  }
  return payload.data;
}

async function waitForEvent(emitter, name, timeoutMs = 5000) {
  return new Promise((resolve, reject) => {
    const timer = setTimeout(() => {
      emitter.off(name, receive);
      reject(new Error(`Timed out waiting for ${name}.`));
    }, timeoutMs);
    const receive = (payload) => {
      clearTimeout(timer);
      resolve(payload);
    };
    emitter.once(name, receive);
  });
}

function assert(condition, message) {
  if (!condition) throw new Error(message);
}

async function runHttpFlow() {
  await request('/sim/context', 'POST', { values: { energyKw: 6.4 } });

  const eventResult = await request('/sim/event', 'POST', {
    eventType: 'window.opened',
    payload: { deviceId, roomId: 'bedroom' },
    occurredAt: new Date().toISOString(),
  });
  const [command] = await request('/sim/commands');
  assert(command && command.executionId === eventResult.execution.id, 'Window rule did not queue a command.');
  await request(`/sim/commands/${command.id}/result`, 'POST', {
    success: true,
    state: { enabled: false },
  });

  const execution = await request(`/explain/${eventResult.execution.id}`);
  const stages = execution.trace.map((step) => step.stage);
  for (const stage of ['trigger', 'rule', 'priority', 'command', 'acknowledgement']) {
    assert(stages.includes(stage), `Execution trace is missing "${stage}".`);
  }
  assert(execution.status === 'succeeded', 'Successful simulator acknowledgement did not complete the execution.');
  console.log(`HTTP rule flow: ${eventResult.event.eventType} -> priority resolution -> ${command.command} -> acknowledged`);

  await request('/sim/context', 'POST', {
    values: {
      occupancy: 2,
      bedroomWindowOpen: false,
      guestMode: true,
      energyKw: 6.4,
    },
  });
  const excepted = await request('/sim/event', 'POST', {
    eventType: 'temperature.changed',
    payload: { deviceId: 'living-room-heater' },
    occurredAt: new Date().toISOString(),
  });
  assert(excepted.execution.status === 'skipped', 'The active exception did not skip its rule.');
  assert(
    excepted.execution.trace.some((step) => step.stage === 'exception'),
    'The execution trace did not record the exception.',
  );
  await request('/sim/context', 'POST', {
    values: {
      occupancy: 2,
      bedroomWindowOpen: false,
      guestMode: false,
      energyKw: 6.4,
    },
  });
  console.log('Exception flow: actual context matched the exception and skipped the action');

  const override = await request('/overrides', 'POST', {
    deviceId: 'living-room-heater',
    value: { enabled: false },
    expiresAt: new Date(Date.now() + 60000).toISOString(),
  });
  const overridden = await request('/sim/event', 'POST', {
    eventType: 'energy.peak',
    payload: { energyKw: 6.4 },
    occurredAt: new Date().toISOString(),
  });
  assert(overridden.execution.status === 'skipped', 'The active override did not skip its action.');
  assert(
    overridden.execution.trace.some((step) => step.stage === 'override'),
    'The execution trace did not record the active override.',
  );
  await request(`/overrides/${override.id}`, 'DELETE');
  console.log('Override flow: active override prevented a device command');

  const peak = await request('/sim/event', 'POST', {
    eventType: 'energy.peak',
    payload: { energyKw: 6.4 },
    occurredAt: new Date().toISOString(),
  });
  let [retryCommand] = await request('/sim/commands');
  assert(retryCommand && retryCommand.executionId === peak.execution.id, 'Peak rule did not queue its command.');
  const retryCommandId = retryCommand.id;
  await request(`/sim/commands/${retryCommand.id}/result`, 'POST', {
    success: false,
    error: 'simulated transient failure',
  });
  [retryCommand] = await request('/sim/commands');
  assert(retryCommand && retryCommand.id === retryCommandId, 'Failed command was not retried.');
  await request(`/sim/commands/${retryCommand.id}/result`, 'POST', {
    success: false,
    error: 'simulated terminal failure',
  });
  const [fallback] = await request('/sim/commands');
  assert(fallback && fallback.executionId === peak.execution.id, 'Failure did not queue the configured fallback.');
  await request(`/sim/commands/${fallback.id}/result`, 'POST', { success: true });

  const recoveredExecution = await request(`/explain/${peak.execution.id}`);
  const recoveryStages = recoveredExecution.trace.map((step) => step.stage);
  for (const stage of ['retry', 'failure', 'fallback', 'acknowledgement']) {
    assert(recoveryStages.includes(stage), `Recovery trace is missing "${stage}".`);
  }
  const conditionTrace = recoveredExecution.trace.find(
    (step) => step.stage === 'condition' && step.actual !== undefined,
  );
  assert(
    conditionTrace && conditionTrace.actual === 6.4 && conditionTrace.expected === 5.5,
    'Condition trace did not preserve the actual and expected values.',
  );
  console.log(`Retry/fallback flow: ${recoveryStages.filter((stage) => ['retry', 'failure', 'fallback'].includes(stage)).join(' -> ')}`);

  const manual = await request(`/devices/${deviceId}/command`, 'POST', {
    command: 'power_off',
    parameters: {},
  });
  const alertsBeforeFailure = (await request('/dashboard/summary')).alerts.length;
  let [manualCommand] = await request('/sim/commands');
  await request(`/sim/commands/${manualCommand.id}/result`, 'POST', {
    success: false,
    error: 'simulated unavailable device',
  });
  [manualCommand] = await request('/sim/commands');
  await request(`/sim/commands/${manualCommand.id}/result`, 'POST', {
    success: false,
    error: 'simulated unavailable device',
  });
  const alerts = await request('/dashboard/summary');
  assert(
    alerts.alerts.length > alertsBeforeFailure &&
      alerts.alerts.some((alert) => alert.message.includes(manual.deviceId)),
    'Terminal failure did not create an alert.',
  );
  console.log('Failure flow: retries exhausted -> alert created');
}

async function runSocketFlow() {
  const secret = process.env.JWT_SECRET;
  if (!secret) throw new Error('JWT_SECRET is required to exercise authenticated Socket.IO.');
  const token = jwt.sign({ sub: 'sample-simulator' }, secret, { expiresIn: '5m' });
  const socket = io(socketUrl.toString(), {
    auth: { token },
    transports: ['websocket'],
    reconnection: true,
    reconnectionAttempts: 5,
    reconnectionDelay: 100,
    reconnectionDelayMax: 500,
    randomizationFactor: 0.5,
    timeout: 5000,
  });

  try {
    const ready = await waitForEvent(socket, 'connection:ready');
    assert(
      ['events', 'devices', 'executions', 'alerts', 'context', 'commands']
        .every((channel) => ready.channels.includes(channel)),
      'Socket.IO did not subscribe to all required channels.',
    );
    const commandPromise = waitForEvent(socket, 'command:new');
    const resultPromise = waitForEvent(socket, 'command:result');
    await request('/sim/event', 'POST', {
      eventType: 'window.opened',
      payload: { deviceId, roomId: 'bedroom' },
      occurredAt: new Date().toISOString(),
    });
    const command = await commandPromise;
    const acknowledgement = new Promise((resolve, reject) => {
      socket.emit('command:result', {
        commandId: command.id,
        success: true,
        state: { enabled: false },
      }, (result) => {
        if (result && result.ok) resolve(result);
        else reject(new Error(`Socket command acknowledgement failed: ${JSON.stringify(result)}`));
      });
    });
    await Promise.all([acknowledgement, resultPromise]);
    console.log('Socket.IO flow: authenticated -> command:new -> command:result');

    const reconnected = waitForEvent(socket, 'connection:ready', 10000);
    socket.io.engine.close();
    await reconnected;
    console.log('Socket.IO reconnection: recovered after transport interruption');
  } finally {
    socket.disconnect();
  }
}

async function main() {
  await runHttpFlow();
  await runSocketFlow();
  console.log('Sample simulator completed successfully.');
}

main().catch((error) => {
  console.error('Sample simulator failed:', error);
  process.exitCode = 1;
});
