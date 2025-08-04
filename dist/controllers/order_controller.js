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
exports.OrderController = void 0;
const order_service_1 = require("../services/order_service");
class OrderController {
    // Create a new order
    static ioCreateOrder(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const phoneNumber = (_a = req.user) === null || _a === void 0 ? void 0 : _a.phoneNumber;
                if (!phoneNumber)
                    return res.status(401).json({ message: 'Unauthorized' });
                const result = yield (0, order_service_1.createOrder)(req.body, phoneNumber);
                res.status(201).json(result);
            }
            catch (error) {
                console.error('Error in ioCreateOrder:', error);
                res.status(500).json({ message: 'Server error while creating order' });
            }
        });
    }
    // Get all orders for the user
    static ioGetOrders(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const phoneNumber = (_a = req.user) === null || _a === void 0 ? void 0 : _a.phoneNumber;
                if (!phoneNumber)
                    return res.status(401).json({ message: 'Unauthorized' });
                const result = yield (0, order_service_1.getOrders)(phoneNumber);
                res.json(result);
            }
            catch (error) {
                console.error('Error in ioGetOrders:', error);
                res.status(500).json({ message: 'Server error while fetching orders' });
            }
        });
    }
    static ioUpdateOrder(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const phoneNumber = (_a = req.user) === null || _a === void 0 ? void 0 : _a.phoneNumber;
                if (!phoneNumber)
                    return res.status(401).json({ message: 'Unauthorized' });
                const { orderId, status } = req.body;
                if (!orderId || !status) {
                    return res.status(400).json({ message: 'Missing orderId or status' });
                }
                const result = yield (0, order_service_1.updateOrder)(orderId, status, phoneNumber);
                res.json(result);
            }
            catch (error) {
                console.error('Error in ioUpdateOrder:', error);
                res.status(500).json({ message: 'Server error while updating order' });
            }
        });
    }
}
exports.OrderController = OrderController;
