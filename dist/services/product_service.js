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
exports.deleteProduct = exports.updateProduct = exports.getProductList = exports.createProduct = void 0;
const product_model_1 = require("../models/product_model");
const createProduct = (data, phoneNumber) => __awaiter(void 0, void 0, void 0, function* () {
    return yield product_model_1.ProductModel.create(Object.assign(Object.assign({}, data), { userPhone: phoneNumber }));
});
exports.createProduct = createProduct;
const getProductList = () => __awaiter(void 0, void 0, void 0, function* () {
    return yield product_model_1.ProductModel.find().lean();
});
exports.getProductList = getProductList;
const updateProduct = (data) => __awaiter(void 0, void 0, void 0, function* () {
    if (!data || typeof data !== 'object') {
        throw new Error('Invalid or missing product data');
    }
    const { id, productName, productDescription, productPrice, productCategory, productImage, } = data;
    if (!id) {
        throw new Error('Product ID is required');
    }
    console.log('Looking for productId:', id);
    const updated = yield product_model_1.ProductModel.findOneAndUpdate({ productId: id }, Object.assign(Object.assign(Object.assign(Object.assign(Object.assign({}, (productName && { productName })), (productDescription && { productDescription })), (productPrice && { productPrice })), (productCategory && { productCategory })), (productImage && { productImage })), { new: true });
    if (!updated) {
        throw new Error('Product not found');
    }
    return updated;
});
exports.updateProduct = updateProduct;
const deleteProduct = (data, phoneNumber) => __awaiter(void 0, void 0, void 0, function* () {
    return yield product_model_1.ProductModel.findOneAndDelete({ productId: data.id });
});
exports.deleteProduct = deleteProduct;
