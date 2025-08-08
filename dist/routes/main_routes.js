"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.productionRoutes = productionRoutes;
const otp_controller_1 = require("../controllers/otp_controller");
const auth_service_1 = require("../services/auth_service");
const auth_controller_1 = require("../controllers/auth_controller");
const order_controller_1 = require("../controllers/order_controller");
const upload_middleware_1 = require("../services/upload_middleware");
const cart_controller_1 = require("../controllers/cart_controller");
const admin_service_1 = require("../services/admin_service");
const product_controller_1 = require("../controllers/product_controller");
const wishlist_controller_1 = require("../controllers/wishlist_controller");
const admin_controller_1 = require("../controllers/admin_controller");
const user_controller_1 = require("../controllers/user_controller");
function productionRoutes(app) {
    // admin routes
    app.post('/admin/create', admin_controller_1.AdminController.createAdmin);
    app.post('/admin/users/list', auth_service_1.authenticateToken, admin_service_1.isAdmin, admin_controller_1.AdminController.ioGetUsers);
    //order
    app.post('/orders/create', auth_service_1.authenticateToken, order_controller_1.OrderController.ioCreateOrder);
    app.post('/orders/list', auth_service_1.authenticateToken, order_controller_1.OrderController.ioGetOrders);
    app.put('/orders/update', auth_service_1.authenticateToken, admin_service_1.isAdmin, order_controller_1.OrderController.ioUpdateOrder);
    //wishlist
    app.post('/wishlist/add', auth_service_1.authenticateToken, wishlist_controller_1.WishlistController.ioAddToWishlist);
    app.post('/wishlist/get', auth_service_1.authenticateToken, wishlist_controller_1.WishlistController.ioGetWishlist);
    app.post('/wishlist/remove', auth_service_1.authenticateToken, wishlist_controller_1.WishlistController.ioRemoveFromWishlist);
    //cart
    app.post('/cart_array/create', auth_service_1.authenticateToken, cart_controller_1.CartController.ioCreateCart);
    app.post('/cart_array/getdata', auth_service_1.authenticateToken, cart_controller_1.CartController.ioGetCartList);
    app.post('/cart_array/update', auth_service_1.authenticateToken, cart_controller_1.CartController.ioUpdateCart);
    app.post('/cart_array/delete', auth_service_1.authenticateToken, cart_controller_1.CartController.ioDeleteCart);
    app.post('/product_array/create', auth_service_1.authenticateToken, admin_service_1.isAdmin, upload_middleware_1.upload.single('productImage'), admin_service_1.isAdmin, product_controller_1.ProductController.ioCreateProduct);
    app.post('/product_array/getdata', auth_service_1.authenticateToken, product_controller_1.ProductController.ioGetProductList);
    app.post('/product_array/update', auth_service_1.authenticateToken, admin_service_1.isAdmin, product_controller_1.ProductController.ioUpdateProduct);
    app.post('/product_array/delete', auth_service_1.authenticateToken, admin_service_1.isAdmin, product_controller_1.ProductController.ioDeleteProduct);
    app.post('/api/number/generate', otp_controller_1.OtpController.ioGenerateNumber);
    app.get('/api/otp/generate/:number', otp_controller_1.OtpController.ioGenerateOtp);
    app.post('/api/number/verify', otp_controller_1.OtpController.ioVerifyNumber);
    app.post('/api/logout', otp_controller_1.OtpController.ioLogout);
    app.post('/user/register', user_controller_1.UserController.ioRegisterUser);
    app.post('/user/profile', auth_service_1.authenticateToken, user_controller_1.UserController.ioGetUserProfile);
    app.post('/auth/refresh', auth_controller_1.AuthController.ioRefreshToken);
    app.post('/auth/login', auth_controller_1.AuthController.ioLogin);
    app.post('/auth/profile', auth_service_1.authenticateToken, auth_controller_1.AuthController.ioProtectedProfile);
}
