import { Request, Response } from 'express';
import { AdminModel} from '../models/admin_model';
import { getAllUsers} from '../services/admin_service'
export class AdminController {
  static async createAdmin(req: Request, res: Response) {
    const { phoneNumber } = req.body;

    if (!phoneNumber) {
      return res.status(400).json({ message: 'Phone number is required' });
    }

    try {
      // Check if an admin already exists
      const existingAdmin = await AdminModel.findOne({ isAdmin: true });
      if (existingAdmin) {
        return res.status(403).json({ message: 'Admin already exists' });
      }

      // Check if user exists
      let user = await AdminModel.findOne({ phoneNumber });

      if (user) {
        user.isAdmin = true;
        await user.save();
      } else {
        user = await AdminModel.create({ phoneNumber, isAdmin: true });
      }

      return res.status(200).json({
        message: 'Admin user created successfully',
        user,
      });
    } catch (error) {
      return res.status(500).json({ message: 'Internal Server Error', error });
    }
  }
  static async ioGetUsers(req: Request, res: Response) {
    try {
    const result = await getAllUsers();
    res.json(result);
    } catch (error) {
    res.status(500).json({ message: 'Server error' });
    }
  } 
}