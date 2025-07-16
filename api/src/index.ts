import { PrismaClient } from "@prisma/client";
import cors from "cors";
import { config } from "dotenv";
import express from "express";
import authRouter from "./routes/auth.router";
import likeRouter from "./routes/like.router";
import userRouter from "./routes/user.router";
import viewRouter from "./routes/view.router";
import { isAuthenticated } from "./utils/middleware";

config();

export const prisma = new PrismaClient();

export const app = express();
app.use(cors());
app.use(express.json());

app.use("/api/auth", authRouter);
app.use("/api/user", userRouter);
app.use("/api/like", isAuthenticated, likeRouter);
app.use("/api/view", isAuthenticated, viewRouter);

app.listen(process.env.PORT, () => {
  console.log(`Server is running on http://localhost:${process.env.PORT}`);
});
