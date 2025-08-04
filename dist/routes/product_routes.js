"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.configureCartRoutes = configureCartRoutes;
exports.configureProductRoutes = configureProductRoutes;
const upload_middleware_1 = require("../services/upload_middleware");
const auth_middleware_1 = require("../services/auth_middleware");
const product_controller_1 = require("../controllers/product_controller");
function configureCartRoutes(app) {
    app.post('/cart_array/create', auth_middleware_1.authenticateToken, product_controller_1.ioCreateCart);
    app.post('/cart_array/getdata', auth_middleware_1.authenticateToken, product_controller_1.ioGetCartList);
    app.post('/cart_array/update', auth_middleware_1.authenticateToken, product_controller_1.ioUpdateCart);
    app.post('/cart_array/delete', auth_middleware_1.authenticateToken, product_controller_1.ioDeleteCart);
}
function configureProductRoutes(app) {
    app.post('/product_array/create', auth_middleware_1.authenticateToken, upload_middleware_1.upload.single('productImage'), product_controller_1.ioCreateProduct);
    app.post('/product_array/getdata', auth_middleware_1.authenticateToken, product_controller_1.ioGetProductList);
    app.post('/product_array/update', auth_middleware_1.authenticateToken, product_controller_1.ioUpdateProduct);
    app.post('/product_array/delete', auth_middleware_1.authenticateToken, product_controller_1.ioDeleteProduct);
}
