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
exports.ProductController = void 0;
const product_service_1 = require("../services/product_service");
class ProductController {
    // 📦 Create a new product
    static ioCreateProduct(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const phoneNumber = (_a = req.user) === null || _a === void 0 ? void 0 : _a.phoneNumber;
                const { productName, productDescription, productPrice, productCategory } = req.body;
                if (!req.file) {
                    return res.status(400).json({ message: 'Image file is required' });
                }
                const productImage = req.file.filename;
                const result = yield (0, product_service_1.createProduct)({
                    productName,
                    productDescription,
                    productPrice,
                    productCategory,
                    productImage,
                }, phoneNumber);
                res.status(201).json(result);
            }
            catch (error) {
                console.error('Error in ioCreateProduct:', error);
                res.status(500).json({ message: 'Server error', error });
            }
        });
    }
    // 📦 Get product list
    static ioGetProductList(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const result = yield (0, product_service_1.getProductList)();
                res.json(result);
            }
            catch (error) {
                console.error('Error in ioGetProductList:', error);
                res.status(500).json({ message: 'Server error' });
            }
        });
    }
    // 📦 Update product
    static ioUpdateProduct(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const result = yield (0, product_service_1.updateProduct)(req.body);
                res.status(200).json(result);
            }
            catch (error) {
                console.error('Error in ioUpdateProduct:', error);
                res.status(400).json({ message: error.message || 'Failed to update product' });
            }
        });
    }
    // 📦 Delete product
    static ioDeleteProduct(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const phoneNumber = (_a = req.user) === null || _a === void 0 ? void 0 : _a.phoneNumber;
                const result = yield (0, product_service_1.deleteProduct)(req.body, phoneNumber);
                res.json(result);
            }
            catch (error) {
                console.error('Error in ioDeleteProduct:', error);
                res.status(500).json({ message: 'Server error while deleting product' });
            }
        });
    }
}
exports.ProductController = ProductController;
