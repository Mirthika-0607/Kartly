import mongoose from 'mongoose';
import { IVerification } from './verification_model'; // Import IVerification

export interface IAdmin extends IVerification {
  isAdmin: boolean;
}

const adminSchema = new mongoose.Schema<IAdmin>({
  phoneNumber: { type: String, required: true, unique: true }, // Explicitly include for clarity
  isAdmin: { type: Boolean, default: false },
});

export const AdminModel = mongoose.model<IAdmin>('Admin', adminSchema); // Use 'Admin' collection