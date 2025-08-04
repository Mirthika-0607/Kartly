import { Request, Response } from 'express';
import jwt from 'jsonwebtoken';
import { JWT_SECRET, JWT_EXPIRES_IN } from '../config';
import { Verification } from '../models/verification_model';
import { createOrUpdateUser } from './user_service';

// Private function: OTP generator — not exported
const generateOtp = (): string => {
  return Math.floor(1000 + Math.random() * 9000).toString();
};

// 1. Add phone number to verification list
export const handleGenerateNumber = async (req: Request, res: Response) => {
  const { phoneNumber } = req.body;

  if (!phoneNumber || !/^\d{10}$/.test(phoneNumber)) {
    return res.status(400).json({ message: 'Invalid phone number format' });
  }

  const alreadyVerified = await Verification.findVerifiedNumber(phoneNumber);
  if (alreadyVerified) {
    return res.status(409).json({ message: 'Number already verified' });
  }

  await Verification.upsertVerificationEntry(phoneNumber);
  return res.status(201).json({ message: 'Phone number added to verification list' });
};

// 2. Generate OTP
export const handleGenerateOtp = async (req: Request, res: Response) => {
  const phoneNumber = req.params.number;

  if (!phoneNumber || !/^\d{10}$/.test(phoneNumber)) {
    return res.status(400).json({ message: 'Invalid phone number format' });
  }

  const record = await Verification.findByPhoneNumber(phoneNumber);
  if (!record) {
    return res.status(404).json({ message: 'Phone number not found' });
  }

  const otp = generateOtp();
  await Verification.updateOtpForPhone(phoneNumber, otp);

  return res.status(200).json({ message: 'OTP sent', otp });
};

// 3. Verify OTP and generate JWT, create/update user
export const handleVerifyOtp = async (req: Request, res: Response) => {
  const { phoneNumber, otp } = req.body;

  if (!phoneNumber || !/^\d{10}$/.test(phoneNumber)) {
    return res.status(400).json({ message: 'Invalid phone number format' });
  }

  if (!otp || !/^\d{4}$/.test(otp)) {
    return res.status(400).json({ message: 'Invalid OTP format' });
  }

  const entry = await Verification.findByPhoneNumber(phoneNumber);
  if (!entry) {
    return res.status(409).json({ message: 'Number not found for verification' });
  }

  if (!entry.otp || entry.otp !== otp) {
    return res.status(400).json({ message: 'Invalid or expired OTP' });
  }

  const token = jwt.sign({ phoneNumber }, JWT_SECRET as string, {
    expiresIn: JWT_EXPIRES_IN,
  });

  await Verification.verifyNumberAndSaveToken(phoneNumber, token);
  await createOrUpdateUser({ phoneNumber, token });

  return res.status(200).json({ message: 'Number verified and registered successfully', token });
};

export const handleLogout = async (req: Request, res: Response) => {
  const { phoneNumber } = req.body;

  if (!phoneNumber || !/^\d{10}$/.test(phoneNumber)) {
    return res.status(400).json({ message: 'Invalid phone number format' });
  }

  const entry = await Verification.findByPhoneNumber(phoneNumber);
  if (!entry || !entry.isVerified || !entry.token) {
    return res.status(400).json({ message: 'No active session found for this number' });
  }

  await Verification.clearToken(phoneNumber);
  return res.status(200).json({ message: 'Logged out successfully' });
};