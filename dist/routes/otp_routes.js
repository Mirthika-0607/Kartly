"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.configureRoutes = configureRoutes;
const otp_controller_1 = require("../controllers/otp_controller");
const auth_middleware_1 = require("../services/auth_middleware");
function configureRoutes(app) {
    app.post('/api/number/generate', otp_controller_1.OtpController.ioGenerateNumber);
    app.get('/api/otp/generate/:number', otp_controller_1.OtpController.ioGenerateOtp);
    app.post('/api/number/verify', otp_controller_1.OtpController.ioVerifyNumber);
    app.get('/api/user/profile', auth_middleware_1.authenticateToken, otp_controller_1.OtpController.ioProtectedProfile);
}
