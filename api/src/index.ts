import { PrismaClient } from '@prisma/client';
import express from 'express';
import cors from 'cors';
import { config } from 'dotenv';

// Charger les variables d'environnement
config();

import authRouter from './routes/auth.router';
import userRouter from './routes/user.router';

export const prisma = new PrismaClient();

export const app = express();
app.use(cors());
app.use(express.json());

app.use('/api/auth', authRouter);
app.use('/api/user', userRouter);

app.listen(process.env.PORT, () => {
  console.log(`Server is running on http://localhost:${process.env.PORT}`);
});
