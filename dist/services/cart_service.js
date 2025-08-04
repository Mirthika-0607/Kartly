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
exports.deleteCart = exports.updateCart = exports.getCartList = exports.createCart = void 0;
const product_model_1 = require("../models/product_model");
const cart_model_1 = require("../models/cart_model");
const calculateTotalPrice = (items) => __awaiter(void 0, void 0, void 0, function* () {
    let total = 0;
    for (const item of items) {
        const product = yield product_model_1.ProductModel.findOne({ productId: item.productId });
        if (product) {
            const price = product.productPrice || 0;
            const quantity = item.quantity || 0;
            total += price * quantity;
        }
    }
    return total;
});
const createCart = (data, phoneNumber) => __awaiter(void 0, void 0, void 0, function* () {
    const items = data.items;
    const totalPrice = yield calculateTotalPrice(items);
    const cartData = {
        userPhone: phoneNumber,
        items,
        totalPrice,
    };
    return yield cart_model_1.CartModel.create(cartData);
});
exports.createCart = createCart;
const getCartList = (phoneNumber) => __awaiter(void 0, void 0, void 0, function* () {
    return yield cart_model_1.CartModel.find({ userPhone: phoneNumber }) // Filter by user
        .populate('items.productId')
        .lean();
});
exports.getCartList = getCartList;
const updateCart = (data, phoneNumber) => __awaiter(void 0, void 0, void 0, function* () {
    const totalPrice = yield calculateTotalPrice(data.items);
    return yield cart_model_1.CartModel.findOneAndUpdate({ cartId: data.id, userPhone: phoneNumber }, // Ensure it's user's cart
    {
        items: data.items,
        totalPrice,
    }, { new: true });
});
exports.updateCart = updateCart;
const deleteCart = (data, phoneNumber) => __awaiter(void 0, void 0, void 0, function* () {
    return yield cart_model_1.CartModel.findOneAndDelete({ cartId: data.cartId, userPhone: phoneNumber });
});
exports.deleteCart = deleteCart;
