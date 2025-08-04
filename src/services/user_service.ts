import { UserModel, IUser } from '../models/user_model';

export const createOrUpdateUser = async (userData: IUser) => {
  const { phoneNumber, name, address, email, token } = userData;
  const updateFields: any = { name, address, email };

  if (token) {
    // For updates, token is required
    if (await UserModel.findOne({ phoneNumber })) {
      if (!token) {
        throw new Error('Token is required for updating user');
      }
      updateFields.token = token;
    }
  } else {
    // For creation, set createdAt
    updateFields.createdAt = new Date();
  }

  return await UserModel.findOneAndUpdate(
    { phoneNumber },
    { $set: updateFields },
    { upsert: true, new: true, setDefaultsOnInsert: true }
  );
};

export const getUserByPhoneNumber = async (phoneNumber: string) => {
  return await UserModel.findOne({ phoneNumber }).lean();
};