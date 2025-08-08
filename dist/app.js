"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const database_1 = require("./database");
const body_parser_1 = __importDefault(require("body-parser"));
const config_1 = require("./config");
const main_routes_1 = require("./routes/main_routes");
const app = (0, express_1.default)();
app.use((0, cors_1.default)());
app.use(body_parser_1.default.json());
app.use(body_parser_1.default.urlencoded({ extended: true }));
app.use('/uploads', express_1.default.static('uploads'));
app.use((0, cors_1.default)({ origin: '*' }));
app.use(express_1.default.json());
(0, main_routes_1.productionRoutes)(app);
(0, database_1.connectToDatabase)();
app.listen(config_1.PORT, () => {
    console.log(`Server running on port: ${config_1.PORT}`);
});
