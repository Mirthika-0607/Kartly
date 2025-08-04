import mongoose from 'mongoose';

const wishlistSchema = new mongoose.Schema({
  userToken: { type: String, required: true },
  productId: { type: String, required: true },
  createdAt: { type: Date, default: Date.now }
});

export const WishlistModel = mongoose.model('Wishlist', wishlistSchema);
