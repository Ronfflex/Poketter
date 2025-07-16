import { Router } from 'express';
import { login, register, logout } from '../controllers/auth.controller';
import { z } from 'zod';

const authRouter = Router();

const userRegisterSchema = z.object({
  username: z.string().min(3).max(20),
  email: z.string().email(),
  password: z.string().min(6),
});

authRouter.post('/register', async (req, res) => {
  try {
    const data = userRegisterSchema.parse(req.body);
    const { username, password, email } = data;
    const newUser = await register(username, password, email);
    res.status(200).json(newUser);
  } catch (error: any) {
    res.status(400).json({ error: error.message });
  }
});

const userLoginSchema = z.object({
  username: z.string().min(3).max(20),
  password: z.string().min(6),
});

authRouter.post('/login', async (req, res) => {
  try {
    const data = userLoginSchema.parse(req.body);
    const { username, password } = data;
    const user = await login(username, password);
    res.status(200).json(user);
  } catch (error: any) {
    res.status(400).json({ error: error.message });
  }
});

authRouter.get('/logout', async (req, res) => {
  try {
    const { authorization } = req.headers;
    if (!authorization) throw new Error('Authorization header is required');
    const authToken = authorization.split(' ')[1];
    const user = await logout(authToken);
    res.status(200).json({ message: 'You just logout', user });
  } catch (error: any) {
    res.status(400).json({ error: error.message });
  }
});

export default authRouter;
