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
exports.removeFromWishlist = exports.getWishlist = exports.addToWishlist = void 0;
const wishlist_model_1 = require("../models/wishlist_model");
const addToWishlist = (productId, phoneNumber) => __awaiter(void 0, void 0, void 0, function* () {
    return yield wishlist_model_1.WishlistModel.create({ userToken: phoneNumber, productId });
});
exports.addToWishlist = addToWishlist;
const getWishlist = (phoneNumber) => __awaiter(void 0, void 0, void 0, function* () {
    return yield wishlist_model_1.WishlistModel.find({ userToken: phoneNumber });
});
exports.getWishlist = getWishlist;
const removeFromWishlist = (productId, phoneNumber) => __awaiter(void 0, void 0, void 0, function* () {
    return yield wishlist_model_1.WishlistModel.deleteOne({ userToken: phoneNumber, productId });
});
exports.removeFromWishlist = removeFromWishlist;
