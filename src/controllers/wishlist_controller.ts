// src/controllers/wishlist_controller.ts
import { Request, Response } from 'express';
import {
  addToWishlist,
  getWishlist,
  removeFromWishlist,
} from '../services/wishlist_service';

export class WishlistController {
  // ➕ Add to wishlist
  static async ioAddToWishlist(req: Request, res: Response) {
    try {
      const phoneNumber = (req as any).user?.phoneNumber;
      if (!phoneNumber) {
        return res.status(401).json({ message: 'Unauthorized' });
      }

      const { productId } = req.body;
      const result = await addToWishlist(productId, phoneNumber);
      res.json(result);
    } catch (error) {
      console.error('Error in ioAddToWishlist:', error);
      res.status(500).json({ message: 'Server error' });
    }
  }

  // 📃 Get wishlist
  static async ioGetWishlist(req: Request, res: Response) {
    try {
      const phoneNumber = (req as any).user?.phoneNumber;
        if (!phoneNumber) {
          return res.status(401).json({ message: 'Unauthorized' });
        }
      const result = await getWishlist(phoneNumber);
      res.json(result);
    } catch (error) {
        console.error('Error in ioGetWishlist:', error);
        res.status(500).json({ message: 'Server error' });
    }
  }

  // ❌ Remove from wishlist
  static async ioRemoveFromWishlist(req: Request, res: Response) {
    try {
      const phoneNumber = (req as any).user?.phoneNumber;
      if (!phoneNumber) {
        return res.status(401).json({ message: 'Unauthorized' });
      }

      const { productId } = req.body;
      const result = await removeFromWishlist(productId, phoneNumber);
      res.json(result);
    } catch (error) {
      console.error('Error in ioRemoveFromWishlist:', error);
      res.status(500).json({ message: 'Server error' });
    }
  }
}
