import mongoose from 'mongoose';

// 1. Interface
export interface IVerification {
  phoneNumber: string;
  otp?: string;
  otpCreatedAt?: Date;
  isVerified?: boolean;
  verifiedAt?: Date;
  token?: string;
}

// 2. Schema — no required/default
const verificationSchema = new mongoose.Schema<IVerification>({
  phoneNumber: { type: String },
  otp: { type: String },
  otpCreatedAt: { type: Date },
  isVerified: { type: Boolean },
  verifiedAt: { type: Date },
  token: { type: String }
});

// 3. Base model
const BaseVerificationModel = mongoose.model<IVerification>(
  'Verification',
  verificationSchema,
  'user_verifications'
);

// 4. Model class with methods
export class Verification {
  static async findVerifiedNumber(phoneNumber: string) {
    return BaseVerificationModel.findOne({ phoneNumber, isVerified: true }).lean();
  }

  static async upsertVerificationEntry(phoneNumber: string) {
    return BaseVerificationModel.findOneAndUpdate(
      { phoneNumber },
      {
        phoneNumber,
        isVerified: false,
        verifiedAt: new Date(0),
        otp: '',
        otpCreatedAt: new Date(0),
        token: ''
      },
      { upsert: true, new: true }
    ).lean();
  }

  static async findByPhoneNumber(phoneNumber: string) {
    return BaseVerificationModel.findOne({ phoneNumber }).lean();
  }

  static async updateOtpForPhone(phoneNumber: string, otp: string) {
    return BaseVerificationModel.updateOne(
      { phoneNumber },
      {
        otp,
        otpCreatedAt: new Date()
      }
    );
  }

  static async verifyNumberAndSaveToken(phoneNumber: string, token: string) {
    return BaseVerificationModel.updateOne(
      { phoneNumber },
      {
        isVerified: true,
        verifiedAt: new Date(),
        otp: '',
        otpCreatedAt: new Date(0),
        token
      }
    );
  }
  static async clearToken(phoneNumber: string) {
    return BaseVerificationModel.updateOne(
      { phoneNumber },
      {
        token: '',
        isVerified: false,
        verifiedAt: new Date(0)
      }
    );
  }
}
