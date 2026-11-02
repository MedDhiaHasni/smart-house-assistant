"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.runtimeStore = void 0;
exports.createId = createId;
exports.resetRuntimeStore = resetRuntimeStore;
const now = new Date().toISOString();
exports.runtimeStore = {
    simulatedNow: now,
    rules: [
        {
            id: 'window-safety',
            name: 'Open-window heating safety',
            enabled: true,
            trigger: { eventType: 'window.opened' },
            conditions: [],
            exceptions: [],
            actions: [
                {
                    deviceId: 'bedroom-heater',
                    command: 'set',
                    parameters: { enabled: false },
                    maxRetries: 1,
                    fallback: { command: 'power_off', parameters: {} },
                },
            ],
            priority: 100,
        },
        {
            id: 'window-comfort-conflict',
            name: 'Window-open comfort adjustment',
            enabled: true,
            trigger: { eventType: 'window.opened' },
            conditions: [],
            exceptions: [],
            actions: [
                {
                    deviceId: 'bedroom-heater',
                    command: 'set_temperature',
                    parameters: { temperature: 18 },
                    maxRetries: 1,
                },
            ],
            priority: 10,
        },
        {
            id: 'comfort-heating',
            name: 'Comfort heating',
            enabled: true,
            trigger: { eventType: 'temperature.changed' },
            conditions: [
                { variable: 'occupancy', operator: 'greaterThan', expected: 0 },
                { variable: 'bedroomWindowOpen', operator: 'isFalse' },
            ],
            exceptions: [
                { variable: 'guestMode', operator: 'isTrue' },
            ],
            actions: [
                {
                    deviceId: 'living-room-heater',
                    command: 'set_temperature',
                    parameters: { temperature: 21 },
                    maxRetries: 2,
                    fallback: { command: 'power_off', parameters: {} },
                },
            ],
            priority: 40,
        },
        {
            id: 'energy-saver',
            name: 'Peak-hour energy saving',
            enabled: true,
            trigger: { eventType: 'energy.peak' },
            conditions: [
                { variable: 'energyKw', operator: 'greaterThan', expected: 5.5 },
            ],
            exceptions: [],
            actions: [
                {
                    deviceId: 'living-room-heater',
                    command: 'set_power_limit',
                    parameters: { percent: 60 },
                    maxRetries: 1,
                    fallback: { command: 'notify_resident', parameters: {} },
                },
            ],
            priority: 20,
        },
    ],
    context: {
        occupancy: 2,
        weather: 'clear',
        bedroomWindowOpen: false,
        guestMode: false,
        energyKw: 3.2,
    },
    deviceStates: {
        'bedroom-heater': { enabled: true, temperature: 19 },
        'living-room-heater': { enabled: true, temperature: 20 },
        'kitchen-light': { enabled: true },
        'garage-door': { open: false },
    },
    modes: ['Home', 'Away', 'Night', 'Vacation'],
    activeMode: 'Home',
    events: [],
    executions: [],
    commands: [],
    overrides: [],
    alerts: [],
    energyReadings: [],
    lastChanges: {},
};
let idSequence = 0;
function createId(prefix) {
    idSequence += 1;
    return `${prefix}-${Date.now().toString(36)}-${idSequence.toString(36)}`;
}
function resetRuntimeStore() {
    exports.runtimeStore.events.length = 0;
    exports.runtimeStore.executions.length = 0;
    exports.runtimeStore.commands.length = 0;
    exports.runtimeStore.alerts.length = 0;
    exports.runtimeStore.energyReadings.length = 0;
}
