"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.WishlistModel = void 0;
const mongoose_1 = __importDefault(require("mongoose"));
const wishlistSchema = new mongoose_1.default.Schema({
    userToken: { type: String, required: true },
    productId: { type: String, required: true },
    createdAt: { type: Date, default: Date.now }
});
exports.WishlistModel = mongoose_1.default.model('Wishlist', wishlistSchema);
