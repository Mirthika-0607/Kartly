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
exports.AdminController = void 0;
const admin_model_1 = require("../models/admin_model");
const admin_service_1 = require("../services/admin_service");
class AdminController {
    static createAdmin(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            const { phoneNumber } = req.body;
            if (!phoneNumber) {
                return res.status(400).json({ message: 'Phone number is required' });
            }
            try {
                // Check if an admin already exists
                const existingAdmin = yield admin_model_1.AdminModel.findOne({ isAdmin: true });
                if (existingAdmin) {
                    return res.status(403).json({ message: 'Admin already exists' });
                }
                // Check if user exists
                let user = yield admin_model_1.AdminModel.findOne({ phoneNumber });
                if (user) {
                    user.isAdmin = true;
                    yield user.save();
                }
                else {
                    user = yield admin_model_1.AdminModel.create({ phoneNumber, isAdmin: true });
                }
                return res.status(200).json({
                    message: 'Admin user created successfully',
                    user,
                });
            }
            catch (error) {
                return res.status(500).json({ message: 'Internal Server Error', error });
            }
        });
    }
    static ioGetUsers(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const result = yield (0, admin_service_1.getAllUsers)();
                res.json(result);
            }
            catch (error) {
                res.status(500).json({ message: 'Server error' });
            }
        });
    }
}
exports.AdminController = AdminController;
