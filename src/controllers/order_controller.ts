// src/controllers/order_controller.ts
import { Request, Response } from 'express';
import { createOrder, getOrders , updateOrder} from '../services/order_service';

export class OrderController {
  // Create a new order
  static async ioCreateOrder(req: Request, res: Response) {
    try {
      const phoneNumber = (req as any).user?.phoneNumber;
      if (!phoneNumber) return res.status(401).json({ message: 'Unauthorized' });

      const result = await createOrder(req.body, phoneNumber);
      res.status(201).json(result);
    } catch (error) {
      console.error('Error in ioCreateOrder:', error);
      res.status(500).json({ message: 'Server error while creating order' });
    }
  }

  // Get all orders for the user
  static async ioGetOrders(req: Request, res: Response) {
    try {
      const phoneNumber = (req as any).user?.phoneNumber;
      if (!phoneNumber) return res.status(401).json({ message: 'Unauthorized' });

      const result = await getOrders(phoneNumber);
      res.json(result);
    } catch (error) {
      console.error('Error in ioGetOrders:', error);
      res.status(500).json({ message: 'Server error while fetching orders' });
    }
  }

    static async ioUpdateOrder(req: Request, res: Response) {
    try {
      const phoneNumber = (req as any).user?.phoneNumber;
      if (!phoneNumber) return res.status(401).json({ message: 'Unauthorized' });

      const { orderId, status } = req.body;
      if (!orderId || !status) {
        return res.status(400).json({ message: 'Missing orderId or status' });
      }

      const result = await updateOrder(orderId, status, phoneNumber);
      res.json(result);
    } catch (error) {
      console.error('Error in ioUpdateOrder:', error);
      res.status(500).json({ message: 'Server error while updating order' });
    }
  }

}
