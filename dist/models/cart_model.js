"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.CartModel = void 0;
const crypto_1 = require("crypto");
const mongoose_1 = __importDefault(require("mongoose"));
//  Cart Schema
const cartSchema = new mongoose_1.default.Schema({
    cartId: {
        type: String,
        default: crypto_1.randomUUID,
    },
    userPhone: {
        type: String,
        required: true, // ⬅️ Important for filtering
    },
    items: [
        {
            productId: {
                type: String,
            },
            quantity: {
                type: Number,
                default: 1,
            },
        },
    ],
    totalPrice: {
        type: Number,
        default: 0,
    },
});
exports.CartModel = mongoose_1.default.model('Cart', cartSchema);
