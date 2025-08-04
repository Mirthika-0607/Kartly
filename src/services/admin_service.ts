// src/services/admin_service.ts
import { Request, Response, NextFunction } from 'express';
import { AdminModel } from '../models/admin_model';

export const isAdmin = async (req: Request, res: Response, next: NextFunction) => {
  const phoneNumber = (req as any).user?.phoneNumber;

  if (!phoneNumber) {
    return res.status(401).json({ message: 'Unauthorized: No phone number found' });
  }

  const user = await AdminModel.findOne({ phoneNumber });

  if (!user || !user.isAdmin) {
    return res.status(403).json({ message: 'Forbidden: Admins only' });
  }

  next();
};

export const getAllUsers = async () => {
  const users = await AdminModel.find().lean();
  return users.map(user => ({
    phoneNumber: user.phoneNumber,
    isAdmin: user.isAdmin,
  }));
};