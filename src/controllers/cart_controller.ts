// src/controllers/cart_controller.ts
import { Request, Response } from 'express';
import {
  createCart,
  getCartList,
  updateCart,
  deleteCart,
} from '../services/cart_service';

export class CartController {
  static async ioCreateCart(req: Request, res: Response) {
    try {
      const phoneNumber = (req as any).user?.phoneNumber;
      if (!phoneNumber) {
        return res.status(401).json({ message: 'Unauthorized: No phone number found in token' });
      }

      const result = await createCart(req.body, phoneNumber);
      res.json(result);
    } catch (error) {
      console.error('Error in ioCreateCart:', error);
      res.status(500).json({ message: 'Server error' });
    }
  }

  static async ioGetCartList(req: Request, res: Response) {
    try {
      const phoneNumber = (req as any).user?.phoneNumber;
      const result = await getCartList(phoneNumber);
      res.json(result);
    } catch (error) {
      console.error('Error in ioGetCartList:', error);
      res.status(500).json({ message: 'Server error' });
    }
  }

  static async ioUpdateCart(req: Request, res: Response) {
    try {
      const phoneNumber = (req as any).user?.phoneNumber;
      const result = await updateCart(req.body, phoneNumber);
      res.json(result);
    } catch (error) {
      console.error('Error in ioUpdateCart:', error);
      res.status(500).json({ message: 'Server error' });
    }
  }

  static async ioDeleteCart(req: Request, res: Response) {
    try {
      const phoneNumber = (req as any).user?.phoneNumber;
      const result = await deleteCart(req.body, phoneNumber);
      res.json(result);
    } catch (error) {
      console.error('Error in ioDeleteCart:', error);
      res.status(500).json({ message: 'Server error' });
    }
  }
}
