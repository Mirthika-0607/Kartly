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
exports.OtpController = void 0;
const otp_service_1 = require("../services/otp_service");
class OtpController {
    // 1. Add number to verification list (POST)
    static ioGenerateNumber(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                yield (0, otp_service_1.handleGenerateNumber)(req, res);
            }
            catch (error) {
                console.error('Error in ioGenerateNumber:', error);
                res.status(500).json({ message: 'Server error' });
            }
        });
    }
    // 2. Generate OTP (GET)
    static ioGenerateOtp(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                yield (0, otp_service_1.handleGenerateOtp)(req, res);
            }
            catch (error) {
                console.error('Error in ioGenerateOtp:', error);
                res.status(500).json({ message: 'Server error' });
            }
        });
    }
    // 3. Verify OTP (POST)
    static ioVerifyNumber(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                yield (0, otp_service_1.handleVerifyOtp)(req, res);
            }
            catch (error) {
                console.error('Error in ioVerifyNumber:', error);
                res.status(500).json({ message: 'Server error' });
            }
        });
    }
    static ioLogout(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                yield (0, otp_service_1.handleLogout)(req, res);
            }
            catch (error) {
                console.error('Error in ioLogout:', error);
                res.status(500).json({ message: 'Server error' });
            }
        });
    }
}
exports.OtpController = OtpController;
