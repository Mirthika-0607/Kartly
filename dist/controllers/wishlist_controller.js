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
exports.WishlistController = void 0;
const wishlist_service_1 = require("../services/wishlist_service");
class WishlistController {
    // ➕ Add to wishlist
    static ioAddToWishlist(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const phoneNumber = (_a = req.user) === null || _a === void 0 ? void 0 : _a.phoneNumber;
                if (!phoneNumber) {
                    return res.status(401).json({ message: 'Unauthorized' });
                }
                const { productId } = req.body;
                const result = yield (0, wishlist_service_1.addToWishlist)(productId, phoneNumber);
                res.json(result);
            }
            catch (error) {
                console.error('Error in ioAddToWishlist:', error);
                res.status(500).json({ message: 'Server error' });
            }
        });
    }
    // 📃 Get wishlist
    static ioGetWishlist(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const phoneNumber = (_a = req.user) === null || _a === void 0 ? void 0 : _a.phoneNumber;
                if (!phoneNumber) {
                    return res.status(401).json({ message: 'Unauthorized' });
                }
                const result = yield (0, wishlist_service_1.getWishlist)(phoneNumber);
                res.json(result);
            }
            catch (error) {
                console.error('Error in ioGetWishlist:', error);
                res.status(500).json({ message: 'Server error' });
            }
        });
    }
    // ❌ Remove from wishlist
    static ioRemoveFromWishlist(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const phoneNumber = (_a = req.user) === null || _a === void 0 ? void 0 : _a.phoneNumber;
                if (!phoneNumber) {
                    return res.status(401).json({ message: 'Unauthorized' });
                }
                const { productId } = req.body;
                const result = yield (0, wishlist_service_1.removeFromWishlist)(productId, phoneNumber);
                res.json(result);
            }
            catch (error) {
                console.error('Error in ioRemoveFromWishlist:', error);
                res.status(500).json({ message: 'Server error' });
            }
        });
    }
}
exports.WishlistController = WishlistController;
