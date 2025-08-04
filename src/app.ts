import express from 'express';
import bodyParser from 'body-parser';
import { connectToDatabase } from './database';
import { PORT } from './config';
import cors from 'cors';
import {configureAuthRoutes,
  configureCartRoutes,
  configureOrderRoutes,
  configureProductRoutes,
  configureVerificationRoutes,
  configureWishlistRoutes,
  configureUserRoutes} from './routes/main_routes';
import { configureAdminRoutes } from './routes/main_routes';
const app = express();
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use('/uploads', express.static('uploads'));
app.use(cors({ origin: '*' }));

configureVerificationRoutes(app);
configureCartRoutes(app);
configureProductRoutes(app);
configureWishlistRoutes(app);
configureOrderRoutes(app);
configureAuthRoutes(app);
connectToDatabase();
configureAdminRoutes(app);
configureUserRoutes(app);
app.listen(PORT , () => {
  console.log(`🚀 Server running at http://test0.gpstrack.in:${PORT}`);
});
