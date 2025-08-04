import { ProductModel } from '../models/product_model';


export const createProduct = async (data: any, phoneNumber: string) => {
  return await ProductModel.create({ ...data, userPhone: phoneNumber });
};

export const getProductList = async () => {
  return await ProductModel.find().lean();
};

export const updateProduct = async (data: any) => {
  if (!data || typeof data !== 'object') {
    throw new Error('Invalid or missing product data');
  }

  const {
    id,
    productName,
    productDescription,
    productPrice,
    productCategory,
    productImage,
  } = data;

  if (!id) {
    throw new Error('Product ID is required');
  }

  console.log('Looking for productId:', id);

  const updated = await ProductModel.findOneAndUpdate(
    { productId: id },
    {
      ...(productName && { productName }),
      ...(productDescription && { productDescription }),
      ...(productPrice && { productPrice }),
      ...(productCategory && { productCategory }),
      ...(productImage && { productImage }),
    },
    { new: true }
  );

  if (!updated) {
    throw new Error('Product not found');
  }

  return updated;
};

export const deleteProduct = async (data: any, phoneNumber: string) => {
  return await ProductModel.findOneAndDelete({ productId: data.id });
};