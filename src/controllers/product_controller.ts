// src/controllers/product_controller.ts
import { Request, Response } from 'express';
import {
  createProduct,
  getProductList,
  updateProduct,
  deleteProduct,
} from '../services/product_service';

export class ProductController {
  // 📦 Create a new product
  static async ioCreateProduct(req: Request, res: Response) {
    try {
      const phoneNumber = (req as any).user?.phoneNumber;
      const { productName, productDescription, productPrice, productCategory } = req.body;

      if (!req.file) {
        return res.status(400).json({ message: 'Image file is required' });
      }

      const productImage = req.file.filename;

      const result = await createProduct({
        productName,
        productDescription,
        productPrice,
        productCategory,
        productImage,
      }, phoneNumber);

      res.status(201).json(result);
    } catch (error) {
      console.error('Error in ioCreateProduct:', error);
      res.status(500).json({ message: 'Server error', error });
    }
  }

  // 📦 Get product list
  static async ioGetProductList(req: Request, res: Response) {
    try {
      const result = await getProductList();
      res.json(result);
    } catch (error) {
      console.error('Error in ioGetProductList:', error);
      res.status(500).json({ message: 'Server error' });
    }
  }
  // 📦 Update product
  static async ioUpdateProduct(req: Request, res: Response) {
    try {
      const result = await updateProduct(req.body);
      res.status(200).json(result);
    } catch (error: any) {
      console.error('Error in ioUpdateProduct:', error);
      res.status(400).json({ message: error.message || 'Failed to update product' });
    }
  }

  // 📦 Delete product
  static async ioDeleteProduct(req: Request, res: Response) {
    try {
      const phoneNumber = (req as any).user?.phoneNumber;
      const result = await deleteProduct(req.body, phoneNumber);
      res.json(result);
    } catch (error) {
      console.error('Error in ioDeleteProduct:', error);
      res.status(500).json({ message: 'Server error while deleting product' });
    }
  }
}
