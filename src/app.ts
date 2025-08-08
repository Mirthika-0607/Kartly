import express from 'express';
import cors from 'cors';
import { connectToDatabase } from './database';
import bodyParser from 'body-parser';
import { PORT } from './config';
import { productionRoutes } from './routes/main_routes';

const app = express();

app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use('/uploads', express.static('uploads'));
app.use(cors({ origin: '*' }));
app.use(express.json());

productionRoutes(app);

connectToDatabase();

app.listen(PORT, () => {
  console.log(`Server running on port: ${PORT}`);
});