"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AdminModel = void 0;
const mongoose_1 = __importDefault(require("mongoose"));
const adminSchema = new mongoose_1.default.Schema({
    phoneNumber: { type: String, required: true, unique: true }, // Explicitly include for clarity
    isAdmin: { type: Boolean, default: false },
});
exports.AdminModel = mongoose_1.default.model('Admin', adminSchema); // Use 'Admin' collection
