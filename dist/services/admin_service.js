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
exports.getAllUsers = exports.isAdmin = void 0;
const admin_model_1 = require("../models/admin_model");
const isAdmin = (req, res, next) => __awaiter(void 0, void 0, void 0, function* () {
    var _a;
    const phoneNumber = (_a = req.user) === null || _a === void 0 ? void 0 : _a.phoneNumber;
    if (!phoneNumber) {
        return res.status(401).json({ message: 'Unauthorized: No phone number found' });
    }
    const user = yield admin_model_1.AdminModel.findOne({ phoneNumber });
    if (!user || !user.isAdmin) {
        return res.status(403).json({ message: 'Forbidden: Admins only' });
    }
    next();
});
exports.isAdmin = isAdmin;
const getAllUsers = () => __awaiter(void 0, void 0, void 0, function* () {
    const users = yield admin_model_1.AdminModel.find().lean();
    return users.map(user => ({
        phoneNumber: user.phoneNumber,
        isAdmin: user.isAdmin,
    }));
});
exports.getAllUsers = getAllUsers;
