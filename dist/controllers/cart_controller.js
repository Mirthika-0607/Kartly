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
exports.CartController = void 0;
const cart_service_1 = require("../services/cart_service");
class CartController {
    static ioCreateCart(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const phoneNumber = (_a = req.user) === null || _a === void 0 ? void 0 : _a.phoneNumber;
                if (!phoneNumber) {
                    return res.status(401).json({ message: 'Unauthorized: No phone number found in token' });
                }
                const result = yield (0, cart_service_1.createCart)(req.body, phoneNumber);
                res.json(result);
            }
            catch (error) {
                console.error('Error in ioCreateCart:', error);
                res.status(500).json({ message: 'Server error' });
            }
        });
    }
    static ioGetCartList(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const phoneNumber = (_a = req.user) === null || _a === void 0 ? void 0 : _a.phoneNumber;
                const result = yield (0, cart_service_1.getCartList)(phoneNumber);
                res.json(result);
            }
            catch (error) {
                console.error('Error in ioGetCartList:', error);
                res.status(500).json({ message: 'Server error' });
            }
        });
    }
    static ioUpdateCart(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const phoneNumber = (_a = req.user) === null || _a === void 0 ? void 0 : _a.phoneNumber;
                const result = yield (0, cart_service_1.updateCart)(req.body, phoneNumber);
                res.json(result);
            }
            catch (error) {
                console.error('Error in ioUpdateCart:', error);
                res.status(500).json({ message: 'Server error' });
            }
        });
    }
    static ioDeleteCart(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const phoneNumber = (_a = req.user) === null || _a === void 0 ? void 0 : _a.phoneNumber;
                const result = yield (0, cart_service_1.deleteCart)(req.body, phoneNumber);
                res.json(result);
            }
            catch (error) {
                console.error('Error in ioDeleteCart:', error);
                res.status(500).json({ message: 'Server error' });
            }
        });
    }
}
exports.CartController = CartController;
