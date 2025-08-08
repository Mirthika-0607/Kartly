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
    const { user } = req.body;

    if (!user || !user.phoneNumber || !user.token) {
      return res.status(400).json({ message: 'Phone number and token are required' });
    }

    const foundUser = await getUserByPhoneNumber(user.phoneNumber);
    if (!foundUser) {
      return res.status(404).json({ message: 'User not found' });
    }

    return res.json(foundUser);
  } catch (error) {
    console.error('Error in ioGetUserProfile:', error);
    return res.status(500).json({ message: 'Server error' });
  }
}
}