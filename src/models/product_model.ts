import mongoose from 'mongoose';

export interface IProduct {
  productId: string;
  productName?: string | null | undefined;
  productDescription?: string | null | undefined;
  productPrice?: number | null | undefined;
  productCategory?: string | null | undefined;
  productImage?: string | null | undefined;
  createdAt?: Date; // Add createdAt to the interface
}

const productSchema = new mongoose.Schema<IProduct>({
  productId: { type: String, required: true },
  productName: { type: String },
  productDescription: { type: String },
  productPrice: { type: Number },
  productCategory: { type: String },
  productImage: { type: String },
}, { timestamps: true }); // Enable timestamps

export const ProductModel = mongoose.model<IProduct>('Product', productSchema);