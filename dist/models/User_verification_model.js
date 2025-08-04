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
exports.VerificationModel = exports.verifyNumberAndSaveToken = exports.updateOtpForPhone = exports.findByPhoneNumber = exports.upsertVerificationEntry = exports.findVerifiedNumber = void 0;
// models/verification.ts
const mongoose_1 = __importDefault(require("mongoose"));
const verificationSchema = new mongoose_1.default.Schema({
    phoneNumber: { type: String },
    otp: { type: String },
    otpCreatedAt: { type: Date },
    isVerified: { type: Boolean },
    verifiedAt: { type: Date },
    token: { type: String }
});
const VerificationModel = mongoose_1.default.model('Verification', verificationSchema, 'user_verifications');
exports.VerificationModel = VerificationModel;
const findVerifiedNumber = (phoneNumber) => __awaiter(void 0, void 0, void 0, function* () {
    return yield VerificationModel.findOne({ phoneNumber, isVerified: true }).lean();
});
exports.findVerifiedNumber = findVerifiedNumber;
const upsertVerificationEntry = (phoneNumber) => __awaiter(void 0, void 0, void 0, function* () {
    return yield VerificationModel.findOneAndUpdate({ phoneNumber }, {
        phoneNumber,
        isVerified: false,
        verifiedAt: new Date(0),
        otp: '',
        otpCreatedAt: new Date(0),
        token: ''
    }, { upsert: true, new: true }).lean();
});
exports.upsertVerificationEntry = upsertVerificationEntry;
const findByPhoneNumber = (phoneNumber) => __awaiter(void 0, void 0, void 0, function* () {
    return yield VerificationModel.findOne({ phoneNumber }).lean();
});
exports.findByPhoneNumber = findByPhoneNumber;
const updateOtpForPhone = (phoneNumber, otp) => __awaiter(void 0, void 0, void 0, function* () {
    return yield VerificationModel.updateOne({ phoneNumber }, {
        otp,
        otpCreatedAt: new Date()
    });
});
exports.updateOtpForPhone = updateOtpForPhone;
const verifyNumberAndSaveToken = (phoneNumber, token) => __awaiter(void 0, void 0, void 0, function* () {
    return yield VerificationModel.updateOne({ phoneNumber }, {
        isVerified: true,
        verifiedAt: new Date(),
        otp: '',
        otpCreatedAt: new Date(0),
        token
    });
});
exports.verifyNumberAndSaveToken = verifyNumberAndSaveToken;
