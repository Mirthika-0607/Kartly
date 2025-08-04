import { Request, Response } from 'express';
import { createOrUpdateUser, getUserByPhoneNumber } from '../services/user_service';

export class UserController {
  static async ioRegisterUser(req: Request, res: Response) {
    try {
      const { phoneNumber, name, address, email, token } = req.body;

      if (!phoneNumber || !name || !address || !email) {
        return res.status(400).json({ message: 'All fields (phoneNumber, name, address, email) are required' });
      }
      
      const user = await createOrUpdateUser({ phoneNumber, name, address, email, token });

      res.status(201).json({ message: 'User registered successfully', user });
    } catch (error) {
      console.error('Error in ioRegisterUser:', error);
      res.status(500).json({ message: 'Server error', error });
    }
  }

  static async ioGetUserProfile(req: Request, res: Response) {
    try {
      const phoneNumber = (req as any).user?.phoneNumber;
      const token = (req as any).user?.token;

      if (!token) {
        return res.status(401).json({ message: 'Token is required' });
      }

      const user = await getUserByPhoneNumber(phoneNumber);
      if (!user) {
        return res.status(404).json({ message: 'User not found' });
      }
      res.json(user);
    } catch (error) {
      console.error('Error in ioGetUserProfile:', error);
      res.status(500).json({ message: 'Server error' });
    }
  }
}