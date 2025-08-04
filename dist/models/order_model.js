"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.OrderModel = void 0;
const mongoose_1 = __importDefault(require("mongoose"));
const orderSchema = new mongoose_1.default.Schema({
    orderId: { type: String, required: true },
    userToken: { type: String, required: true },
    items: [
        {
            productId: String,
            quantity: Number,
            price: Number,
        }
    ],
    totalAmount: Number,
    status: { type: String, default: 'pending' },
    createdAt: { type: Date, default: Date.now }
});
exports.OrderModel = mongoose_1.default.model('Order', orderSchema);
