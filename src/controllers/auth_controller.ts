// src/controllers/auth_controller.ts
import { Request, Response } from 'express';
import jwt from 'jsonwebtoken';
import { JWT_SECRET, REFRESH_TOKEN_SECRET } from '../config';
import {handleProtectedProfile} from '../services/auth_service'

export class AuthController {
  // 1. Login and issue tokens
  static async ioLogin(req: Request, res: Response) {
    try {
      const { phoneNumber } = req.body;

      if (!phoneNumber) {
        return res.status(400).json({ message: 'Phone number is required' });
      }

      const accessToken = jwt.sign({ phoneNumber }, JWT_SECRET!, { expiresIn: '2h' });
      const refreshToken = jwt.sign({ phoneNumber }, REFRESH_TOKEN_SECRET!, { expiresIn: '30d' });

      res.json({ accessToken, refreshToken });
    } catch (error) {
      console.error('Error in ioLogin:', error);
      res.status(500).json({ message: 'Server error during login' });
    }
  }

  // 2. Refresh access token using refresh token
  static async ioRefreshToken(req: Request, res: Response) {
    try {
      const { refreshToken } = req.body;

      if (!refreshToken) {
        return res.status(400).json({ message: 'Refresh token is required' });
      }

      const decoded = jwt.verify(refreshToken, REFRESH_TOKEN_SECRET!) as any;

      const accessToken = jwt.sign(
        { phoneNumber: decoded.phoneNumber },
        JWT_SECRET!,
        { expiresIn: '2h' }
      );

      res.json({ accessToken });
    } catch (error) {
      console.error('Error in ioRefreshToken:', error);
      res.status(403).json({ message: 'Invalid or expired refresh token' });
    }
  }

static async ioProtectedProfile(req: Request, res: Response) {
  try {
    await handleProtectedProfile(req, res);
  } catch (error) {
    console.error('Error in ioProtectedProfile:', error);
    res.status(500).json({ message: 'Server error' });
  }
}
}
