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
exports.handleLogout = exports.handleVerifyOtp = exports.handleGenerateOtp = exports.handleGenerateNumber = void 0;
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const config_1 = require("../config");
const verification_model_1 = require("../models/verification_model");
const user_service_1 = require("./user_service");
// Private function: OTP generator — not exported
const generateOtp = () => {
    return Math.floor(1000 + Math.random() * 9000).toString();
};
// 1. Add phone number to verification list
const handleGenerateNumber = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const { phoneNumber } = req.body;
    if (!phoneNumber || !/^\d{10}$/.test(phoneNumber)) {
        return res.status(400).json({ message: 'Invalid phone number format' });
    }
    const alreadyVerified = yield verification_model_1.Verification.findVerifiedNumber(phoneNumber);
    if (alreadyVerified) {
        return res.status(409).json({ message: 'Number already verified' });
    }
    yield verification_model_1.Verification.upsertVerificationEntry(phoneNumber);
    return res.status(201).json({ message: 'Phone number added to verification list' });
});
exports.handleGenerateNumber = handleGenerateNumber;
// 2. Generate OTP
const handleGenerateOtp = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const phoneNumber = req.params.number;
    if (!phoneNumber || !/^\d{10}$/.test(phoneNumber)) {
        return res.status(400).json({ message: 'Invalid phone number format' });
    }
    const record = yield verification_model_1.Verification.findByPhoneNumber(phoneNumber);
    if (!record) {
        return res.status(404).json({ message: 'Phone number not found' });
    }
    const otp = generateOtp();
    yield verification_model_1.Verification.updateOtpForPhone(phoneNumber, otp);
    return res.status(200).json({ message: 'OTP sent', otp });
});
exports.handleGenerateOtp = handleGenerateOtp;
// 3. Verify OTP and generate JWT, create/update user
const handleVerifyOtp = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const { phoneNumber, otp } = req.body;
    if (!phoneNumber || !/^\d{10}$/.test(phoneNumber)) {
        return res.status(400).json({ message: 'Invalid phone number format' });
    }
    if (!otp || !/^\d{4}$/.test(otp)) {
        return res.status(400).json({ message: 'Invalid OTP format' });
    }
    const entry = yield verification_model_1.Verification.findByPhoneNumber(phoneNumber);
    if (!entry) {
        return res.status(409).json({ message: 'Number not found for verification' });
    }
    if (!entry.otp || entry.otp !== otp) {
        return res.status(400).json({ message: 'Invalid or expired OTP' });
    }
    const token = jsonwebtoken_1.default.sign({ phoneNumber }, config_1.JWT_SECRET, {
        expiresIn: config_1.JWT_EXPIRES_IN,
    });
    yield verification_model_1.Verification.verifyNumberAndSaveToken(phoneNumber, token);
    yield (0, user_service_1.createOrUpdateUser)({ phoneNumber, token });
    return res.status(200).json({ message: 'Number verified and registered successfully', token });
});
exports.handleVerifyOtp = handleVerifyOtp;
const handleLogout = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const { phoneNumber } = req.body;
    if (!phoneNumber || !/^\d{10}$/.test(phoneNumber)) {
        return res.status(400).json({ message: 'Invalid phone number format' });
    }
    const entry = yield verification_model_1.Verification.findByPhoneNumber(phoneNumber);
    if (!entry || !entry.isVerified || !entry.token) {
        return res.status(400).json({ message: 'No active session found for this number' });
    }
    yield verification_model_1.Verification.clearToken(phoneNumber);
    return res.status(200).json({ message: 'Logged out successfully' });
});
exports.handleLogout = handleLogout;
