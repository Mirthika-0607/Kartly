"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.configureOrderRoutes = configureOrderRoutes;
const order_controller_1 = require("../controllers/order_controller");
const auth_middleware_1 = require("../services/auth_middleware");
function configureOrderRoutes(app) {
    app.post('/orders/create', auth_middleware_1.authenticateToken, order_controller_1.ioCreateOrder);
    app.get('/orders/list', auth_middleware_1.authenticateToken, order_controller_1.ioGetOrders);
}
