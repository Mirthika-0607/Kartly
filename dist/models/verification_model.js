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
exports.Verification = void 0;
const mongoose_1 = __importDefault(require("mongoose"));
// 2. Schema — no required/default
const verificationSchema = new mongoose_1.default.Schema({
    phoneNumber: { type: String },
    otp: { type: String },
    otpCreatedAt: { type: Date },
    isVerified: { type: Boolean },
    verifiedAt: { type: Date },
    token: { type: String }
});
// 3. Base model
const BaseVerificationModel = mongoose_1.default.model('Verification', verificationSchema, 'user_verifications');
// 4. Model class with methods
class Verification {
    static findVerifiedNumber(phoneNumber) {
        return __awaiter(this, void 0, void 0, function* () {
            return BaseVerificationModel.findOne({ phoneNumber, isVerified: true }).lean();
        });
    }
    static upsertVerificationEntry(phoneNumber) {
        return __awaiter(this, void 0, void 0, function* () {
            return BaseVerificationModel.findOneAndUpdate({ phoneNumber }, {
                phoneNumber,
                isVerified: false,
                verifiedAt: new Date(0),
                otp: '',
                otpCreatedAt: new Date(0),
                token: ''
            }, { upsert: true, new: true }).lean();
        });
    }
    static findByPhoneNumber(phoneNumber) {
        return __awaiter(this, void 0, void 0, function* () {
            return BaseVerificationModel.findOne({ phoneNumber }).lean();
        });
    }
    static updateOtpForPhone(phoneNumber, otp) {
        return __awaiter(this, void 0, void 0, function* () {
            return BaseVerificationModel.updateOne({ phoneNumber }, {
                otp,
                otpCreatedAt: new Date()
            });
        });
    }
    static verifyNumberAndSaveToken(phoneNumber, token) {
        return __awaiter(this, void 0, void 0, function* () {
            return BaseVerificationModel.updateOne({ phoneNumber }, {
                isVerified: true,
                verifiedAt: new Date(),
                otp: '',
                otpCreatedAt: new Date(0),
                token
            });
        });
    }
    static clearToken(phoneNumber) {
        return __awaiter(this, void 0, void 0, function* () {
            return BaseVerificationModel.updateOne({ phoneNumber }, {
                token: '',
                isVerified: false,
                verifiedAt: new Date(0)
            });
        });
    }
}
exports.Verification = Verification;
