import mongoose from 'mongoose';

export interface IUser {
  phoneNumber: string;
  name?: string;
  address?: string;
  email?: string;
  createdAt?: Date;
  token?: string; 
}

const userSchema = new mongoose.Schema<IUser>({
  phoneNumber: { type: String, required: true, unique: true },
  name: { type: String },
  address: { type: String },
  email: { type: String },
  createdAt: { type: Date },
  token: { type: String }, 
}, { timestamps: true });

export const UserModel = mongoose.model<IUser>('User', userSchema, 'users');