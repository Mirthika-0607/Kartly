"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.updateOrder = exports.getOrders = exports.createOrder = void 0;
const order_model_1 = require("../models/order_model");
const createOrder = (data, phoneNumber) => __awaiter(void 0, void 0, void 0, function* () {
    const { items, totalAmount } = data;
    const orderId = 'ORD-' + Date.now();
    return yield order_model_1.OrderModel.create({
        orderId,
        userToken: phoneNumber,
        items,
        totalAmount
    });
});
exports.createOrder = createOrder;
const getOrders = (phoneNumber) => __awaiter(void 0, void 0, void 0, function* () {
    return yield order_model_1.OrderModel.find({ userToken: phoneNumber });
});
exports.getOrders = getOrders;
const updateOrder = (orderId, status, phoneNumber) => __awaiter(void 0, void 0, void 0, function* () {
    return yield order_model_1.OrderModel.findOneAndUpdate({ orderId, userToken: phoneNumber }, { status }, { new: true });
});
exports.updateOrder = updateOrder;
