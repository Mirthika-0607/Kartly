"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.configureWishlistRoutes = configureWishlistRoutes;
const wishlist_controller_1 = require("../controllers/wishlist_controller");
const auth_middleware_1 = require("../services/auth_middleware");
function configureWishlistRoutes(app) {
    app.post('/wishlist/add', auth_middleware_1.authenticateToken, wishlist_controller_1.ioAddToWishlist);
    app.get('/wishlist/get', auth_middleware_1.authenticateToken, wishlist_controller_1.ioGetWishlist);
    app.post('/wishlist/remove', auth_middleware_1.authenticateToken, wishlist_controller_1.ioRemoveFromWishlist);
}
