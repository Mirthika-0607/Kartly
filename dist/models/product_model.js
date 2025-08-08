"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ProductModel = void 0;
const mongoose_1 = __importDefault(require("mongoose"));
const productSchema = new mongoose_1.default.Schema({
    productId: { type: String, required: true },
    productName: { type: String },
    productDescription: { type: String },
    productPrice: { type: Number },
    productCategory: { type: String },
    productImage: { type: String },
    productRating: { type: Number },
}, { timestamps: true }); // Enable timestamps
exports.ProductModel = mongoose_1.default.model('Product', productSchema);
