import mongoose from 'mongoose';

const orderSchema = new mongoose.Schema({
  orderId: { type: String, required: true },
  userToken: { type: String, required: true },
  items: [
    {
      productId: String,
      quantity: Number,
      price: Number,
    }
  ],
  totalAmount: Number,
  status: { type: String, default: 'pending' },
  createdAt: { type: Date, default: Date.now }
});

export const OrderModel = mongoose.model('Order', orderSchema);
