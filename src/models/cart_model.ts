import { randomUUID } from 'crypto';
import mongoose from 'mongoose';

//  Cart Schema

const cartSchema = new mongoose.Schema({
  cartId: {
    type: String,
    default: randomUUID,
  },
  userPhone: {
    type: String,
    required: true, // ⬅️ Important for filtering
  },
  items: [
    {
      productId: {
        type: String,
      },
      quantity: {
        type: Number,
        default: 1,
      },
    },
  ],
  totalPrice: {
    type: Number,
    default: 0,
  },
});
export const CartModel = mongoose.model('Cart', cartSchema);
