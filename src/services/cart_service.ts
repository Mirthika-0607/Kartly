import { ProductModel } from '../models/product_model';
import {CartModel} from '../models/cart_model';

const calculateTotalPrice = async (items: any[]) => {
  let total = 0;

  for (const item of items) {
    const product = await ProductModel.findOne({ productId: item.productId });
    if (product) {
      const price = product.productPrice || 0;
      const quantity = item.quantity || 0;
      total += price * quantity;
    }
  }

  return total;
};

export const createCart = async (data: any, phoneNumber: string) => {
  const items = data.items;
  const totalPrice = await calculateTotalPrice(items);

  const cartData = {
    userPhone: phoneNumber,
    items,
    totalPrice,
  };

  return await CartModel.create(cartData);
};

export const getCartList = async (phoneNumber: string) => {
  return await CartModel.find({ userPhone: phoneNumber }) // Filter by user
    .populate('items.productId')
    .lean();
};

export const updateCart = async (data: any, phoneNumber: string) => {
  const totalPrice = await calculateTotalPrice(data.items);

  return await CartModel.findOneAndUpdate(
    { cartId: data.id, userPhone: phoneNumber }, // Ensure it's user's cart
    {
      items: data.items,
      totalPrice,
    },
    { new: true }
  );
};

export const deleteCart = async (data: any, phoneNumber: string) => {
  return await CartModel.findOneAndDelete({ cartId: data.cartId, userPhone: phoneNumber });
};