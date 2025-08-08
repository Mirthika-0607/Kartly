import mongoose from 'mongoose';

export interface IProduct {
  productId: string;
  productName?: string | null | undefined;
  productDescription?: string | null | undefined;
  productPrice?: string | null | undefined;
  productCategory?: string | null | undefined;
  productImage?: string | null | undefined;
  productRating?: number | null | undefined; 
  createdAt?: Date; 
}

const productSchema = new mongoose.Schema<IProduct>({
  productId: { type: String, required: true },
  productName: { type: String },
  productDescription: { type: String },
  productPrice: { type: String },
  productCategory: { type: String },
  productImage: { type: String },
  productRating: { type: Number },
}, { timestamps: true }); // Enable timestamps

export const ProductModel = mongoose.model<IProduct>('Product', productSchema);