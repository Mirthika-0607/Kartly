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
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthController = void 0;
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const config_1 = require("../config");
const auth_service_1 = require("../services/auth_service");
class AuthController {
    // 1. Login and issue tokens
    static ioLogin(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { phoneNumber } = req.body;
                if (!phoneNumber) {
                    return res.status(400).json({ message: 'Phone number is required' });
                }
                const accessToken = jsonwebtoken_1.default.sign({ phoneNumber }, config_1.JWT_SECRET, { expiresIn: '2h' });
                const refreshToken = jsonwebtoken_1.default.sign({ phoneNumber }, config_1.REFRESH_TOKEN_SECRET, { expiresIn: '30d' });
                res.json({ accessToken, refreshToken });
            }
            catch (error) {
                console.error('Error in ioLogin:', error);
                res.status(500).json({ message: 'Server error during login' });
            }
        });
    }
    // 2. Refresh access token using refresh token
    static ioRefreshToken(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { refreshToken } = req.body;
                if (!refreshToken) {
                    return res.status(400).json({ message: 'Refresh token is required' });
                }
                const decoded = jsonwebtoken_1.default.verify(refreshToken, config_1.REFRESH_TOKEN_SECRET);
                const accessToken = jsonwebtoken_1.default.sign({ phoneNumber: decoded.phoneNumber }, config_1.JWT_SECRET, { expiresIn: '2h' });
                res.json({ accessToken });
            }
            catch (error) {
                console.error('Error in ioRefreshToken:', error);
                res.status(403).json({ message: 'Invalid or expired refresh token' });
            }
        });
    }
    static ioProtectedProfile(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                yield (0, auth_service_1.handleProtectedProfile)(req, res);
            }
            catch (error) {
                console.error('Error in ioProtectedProfile:', error);
                res.status(500).json({ message: 'Server error' });
            }
        });
    }
}
exports.AuthController = AuthController;
