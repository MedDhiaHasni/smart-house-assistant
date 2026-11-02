"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const dashboard_1 = __importDefault(require("./dashboard"));
const context_1 = __importDefault(require("./context"));
const rules_1 = __importDefault(require("./rules"));
const explain_1 = __importDefault(require("./explain"));
const modes_1 = __importDefault(require("./modes"));
const devices_1 = __importDefault(require("./devices"));
const simulator_1 = __importDefault(require("./simulator"));
exports.default = {
    ...dashboard_1.default,
    ...context_1.default,
    ...rules_1.default,
    ...explain_1.default,
    ...modes_1.default,
    ...devices_1.default,
    ...simulator_1.default,
};
