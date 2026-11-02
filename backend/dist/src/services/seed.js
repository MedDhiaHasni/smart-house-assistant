"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.seedDatabase = seedDatabase;
const roles = [
    ['Admin', 'admin'],
    ['Resident', 'resident'],
    ['Simulator', 'simulator'],
];
async function seedDatabase(strapi) {
    const roleService = strapi.plugin('users-permissions').service('role');
    const existingRoles = await roleService.find();
    for (const [name, type] of roles) {
        if (!existingRoles.some((role) => role.type === type)) {
            await roleService.createRole({
                name,
                type,
                description: `${name} role for Smart House Assistant.`,
                permissions: {},
            });
        }
    }
    await ensureRoom(strapi, 'Living room', 0);
    await ensureRoom(strapi, 'Bedroom', 1);
    await ensureRoom(strapi, 'Kitchen', 0);
    await ensureRoom(strapi, 'Garage', 0);
    await ensureOne(strapi, 'api::device.device', 'externalId', 'living-room-heater', {
        externalId: 'living-room-heater',
        name: 'Living room heater',
        category: 'climate',
        state: { enabled: true, temperature: 20 },
        online: true,
    });
    await ensureOne(strapi, 'api::device.device', 'externalId', 'bedroom-heater', {
        externalId: 'bedroom-heater',
        name: 'Bedroom heater',
        category: 'climate',
        state: { enabled: true, temperature: 19 },
        online: true,
    });
    await ensureOne(strapi, 'api::device.device', 'externalId', 'kitchen-light', {
        externalId: 'kitchen-light',
        name: 'Kitchen light',
        category: 'lighting',
        state: { enabled: true },
        online: true,
    });
    await ensureOne(strapi, 'api::device.device', 'externalId', 'garage-door', {
        externalId: 'garage-door',
        name: 'Garage door',
        category: 'security',
        state: { open: false },
        online: true,
    });
    await ensureOne(strapi, 'api::person.person', 'externalId', 'emma', {
        externalId: 'emma',
        name: 'Emma',
        role: 'resident',
        present: true,
        lastSeenAt: new Date().toISOString(),
    });
    await ensureOne(strapi, 'api::context-variable.context-variable', 'key', 'occupancy', {
        key: 'occupancy',
        value: 2,
        source: 'presence-simulator',
        observedAt: new Date().toISOString(),
    });
    for (const rule of [
        {
            name: 'Open-window heating safety',
            enabled: true,
            trigger: { eventType: 'window.opened' },
            conditions: [],
            exceptions: [],
            actions: [{ deviceId: 'bedroom-heater', command: 'set', parameters: { enabled: false } }],
            priority: 100,
        },
        {
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
                },
            ],
            priority: 10,
        },
        {
            name: 'Comfort heating',
            enabled: true,
            trigger: { eventType: 'temperature.changed' },
            conditions: [{ variable: 'occupancy', operator: 'greaterThan', expected: 0 }],
            exceptions: [{ variable: 'bedroomWindowOpen', operator: 'isTrue' }],
            actions: [{ deviceId: 'living-room-heater', command: 'set_temperature', parameters: { temperature: 21 } }],
            priority: 40,
        },
    ]) {
        await ensureOne(strapi, 'api::rule.rule', 'name', rule.name, rule);
    }
    await ensureOne(strapi, 'api::routine.routine', 'name', 'Good morning', {
        name: 'Good morning',
        enabled: true,
        trigger: { eventType: 'time.reached', at: '07:00', days: ['weekday'] },
        conditions: [{ variable: 'occupancy', operator: 'greaterThan', expected: 0 }],
        exceptions: [],
        actions: [{ deviceId: 'kitchen-light', command: 'set', parameters: { enabled: true } }],
        priority: 30,
    });
    await ensureOne(strapi, 'api::energy-reading.energy-reading', 'externalId', 'seed-energy-reading', {
        externalId: 'seed-energy-reading',
        value: 6.3,
        unit: 'kWh',
        measuredAt: new Date().toISOString(),
        source: 'seed',
    });
}
async function ensureRoom(strapi, name, floor) {
    const existing = await strapi.documents('api::room.room').findFirst({
        filters: { name: { $eq: name } },
    });
    if (!existing) {
        await strapi.documents('api::room.room').create({
            data: { name, floor, status: name === 'Living room' ? 'occupied' : 'vacant' },
        });
    }
}
async function ensureOne(strapi, uid, field, value, data) {
    const existing = await strapi.documents(uid).findFirst({
        filters: { [field]: { $eq: value } },
    });
    if (!existing) {
        await strapi.documents(uid).create({ data });
    }
}
