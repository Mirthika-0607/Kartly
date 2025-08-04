"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.getUserByPhoneNumber = exports.createOrUpdateUser = void 0;
const user_model_1 = require("../models/user_model");
const createOrUpdateUser = (userData) => __awaiter(void 0, void 0, void 0, function* () {
    const { phoneNumber, name, address, email, token } = userData;
    const updateFields = { name, address, email };
    if (token) {
        // For updates, token is required
        if (yield user_model_1.UserModel.findOne({ phoneNumber })) {
            if (!token) {
                throw new Error('Token is required for updating user');
            }
            updateFields.token = token;
        }
    }
    else {
        // For creation, set createdAt
        updateFields.createdAt = new Date();
    }
    return yield user_model_1.UserModel.findOneAndUpdate({ phoneNumber }, { $set: updateFields }, { upsert: true, new: true, setDefaultsOnInsert: true });
});
exports.createOrUpdateUser = createOrUpdateUser;
const getUserByPhoneNumber = (phoneNumber) => __awaiter(void 0, void 0, void 0, function* () {
    return yield user_model_1.UserModel.findOne({ phoneNumber }).lean();
});
exports.getUserByPhoneNumber = getUserByPhoneNumber;
