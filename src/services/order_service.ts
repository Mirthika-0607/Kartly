import { OrderModel } from '../models/order_model';

export const createOrder = async (data: any, phoneNumber: string) => {
  const { items, totalAmount } = data;
  const orderId = 'ORD-' + Date.now();
  return await OrderModel.create({
    orderId,
    userToken: phoneNumber,
    items,
    totalAmount
  });
};

export const getOrders = async (phoneNumber: string) => {
  return await OrderModel.find({ userToken: phoneNumber });
};


export const updateOrder = async (orderId: string, status: string, phoneNumber: string) => {
  return await OrderModel.findOneAndUpdate({ orderId, userToken: phoneNumber }, { status }, { new: true });
};