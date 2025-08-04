import { WishlistModel } from '../models/wishlist_model';

export const addToWishlist = async (productId: string, phoneNumber: string) => {
  return await WishlistModel.create({ userToken: phoneNumber, productId });
};

export const getWishlist = async (phoneNumber: string) => {
  return await WishlistModel.find({ userToken: phoneNumber });
};

export const removeFromWishlist = async (productId: string, phoneNumber: string) => {
  return await WishlistModel.deleteOne({ userToken: phoneNumber, productId });
};
