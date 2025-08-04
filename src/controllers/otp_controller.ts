import { Request, Response } from 'express';
import {
  handleGenerateNumber,
  handleGenerateOtp,
  handleVerifyOtp,
  handleLogout
} from '../services/otp_service';

export class OtpController {
  // 1. Add number to verification list (POST)
  static async ioGenerateNumber(req: Request, res: Response) {
    try {
      await handleGenerateNumber(req, res);
    } catch (error) {
      console.error('Error in ioGenerateNumber:', error);
      res.status(500).json({ message: 'Server error' });
    }
  }

  // 2. Generate OTP (GET)
  static async ioGenerateOtp(req: Request, res: Response) {
    try {
      await handleGenerateOtp(req, res);
    } catch (error) {
      console.error('Error in ioGenerateOtp:', error);
      res.status(500).json({ message: 'Server error' });
    }
  }

  // 3. Verify OTP (POST)
  static async ioVerifyNumber(req: Request, res: Response) {
    try {
      await handleVerifyOtp(req, res);
    } catch (error) {
      console.error('Error in ioVerifyNumber:', error);
      res.status(500).json({ message: 'Server error' });
    }
  }

  static async ioLogout(req: Request, res: Response) {
    try {
      await handleLogout(req, res);
    } catch (error) {
      console.error('Error in ioLogout:', error);
      res.status(500).json({ message: 'Server error' });
    }
  }
}
