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
exports.UserController = void 0;
const user_service_1 = require("../services/user_service");
class UserController {
    static ioRegisterUser(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { phoneNumber, name, address, email, token } = req.body;
                if (!phoneNumber || !name || !address || !email) {
                    return res.status(400).json({ message: 'All fields (phoneNumber, name, address, email) are required' });
                }
                const user = yield (0, user_service_1.createOrUpdateUser)({ phoneNumber, name, address, email, token });
                res.status(201).json({ message: 'User registered successfully', user });
            }
            catch (error) {
                console.error('Error in ioRegisterUser:', error);
                res.status(500).json({ message: 'Server error', error });
            }
        });
    }
    static ioGetUserProfile(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { user } = req.body;
                if (!user || !user.phoneNumber || !user.token) {
                    return res.status(400).json({ message: 'Phone number and token are required' });
                }
                const foundUser = yield (0, user_service_1.getUserByPhoneNumber)(user.phoneNumber);
                if (!foundUser) {
                    return res.status(404).json({ message: 'User not found' });
                }
                return res.json(foundUser);
            }
            catch (error) {
                console.error('Error in ioGetUserProfile:', error);
                return res.status(500).json({ message: 'Server error' });
            }
        });
    }
}
exports.UserController = UserController;
