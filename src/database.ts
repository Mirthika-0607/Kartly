import mongoose from 'mongoose';
import { MONGO_URL } from './config';

export const connectToDatabase = async () => {
  try {
    await mongoose.connect(MONGO_URL);
    console.log('Connected to MongoDB mongodb://test0.gpstrack.in:8001/otp_mongo');
  } catch (err) {
    console.error('MongoDB connection error:', err);
  }
};
