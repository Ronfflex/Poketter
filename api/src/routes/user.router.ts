import { Router } from 'express';
import { isAdmin, isAuthenticated } from '../utils/middleware';
import { z } from 'zod';
import {
  createUser,
  deleteUser,
  getAllUsers,
  getUserById,
  getUserByUsername,
  selfUpdate,
  updateUser,
} from '../controllers/user.controller';

const userRouter = Router();

userRouter.get('/profile', isAuthenticated, (req, res) => {
  try {
    res.status(200).json(req.body.user);
  } catch (error: any) {
    res.status(400).json({ error: error.message });
  }
});

const userUpdateSchema = z.object({
  username: z.string().min(3).max(20).optional(),
  email: z.string().email().optional(),
  password: z.string().min(6).optional(),
  role: z.union([z.literal('ADMIN'), z.literal('USER')]).optional(),
});

userRouter.put('/', isAuthenticated, async (req, res) => {
  try {
    const userUpdate = req.body;
    const { username, email, password } = userUpdateSchema.parse(userUpdate);
    const updatedUser = await selfUpdate(
      req.body.user,
      email,
      username,
      password
    );
    res.status(200).json(updatedUser);
  } catch (error: any) {
    res.status(400).json({ error: error.message });
  }
});

userRouter.put('/:id', isAuthenticated, isAdmin, async (req, res) => {
  try {
    const userId = req.params.id;
    const { email, username, password, role } = req.body;
    userUpdateSchema.parse({ email, username, password, role });
    const updatedUser = await updateUser(
      Number(userId),
      email,
      username,
      password,
      role
    );
    res.status(200).json(updatedUser);
  } catch (error: any) {
    res.status(400).json({ error: error.message });
  }
});

userRouter.delete('/:id', isAuthenticated, isAdmin, async (req, res) => {
  try {
    const userId = req.params.id;
    const deletedUser = await deleteUser(Number(userId));
    res.status(200).json(deletedUser);
  } catch (error: any) {
    res.status(400).json({ error: error.message });
  }
});

userRouter.get('/:id', isAuthenticated, isAdmin, async (req, res) => {
  try {
    const userId = req.params.id;
    const user = await getUserById(Number(userId));
    res.status(200).json(user);
  } catch (error: any) {
    res.status(400).json({ error: error.message });
  }
});

userRouter.get(
  '/search/:username',
  isAuthenticated,
  isAdmin,
  async (req, res) => {
    try {
      const username = req.params.username;
      const user = await getUserByUsername(username);
      res.status(200).json(user);
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  }
);

userRouter.get('/', isAuthenticated, isAdmin, async (req, res) => {
  try {
    const users = await getAllUsers();
    res.status(200).json(users);
  } catch (error: any) {
    res.status(400).json({ error: error.message });
  }
});

const userCreateSchema = z.object({
  username: z.string().min(3).max(20),
  email: z.string().email(),
  password: z.string().min(6),
  role: z.union([z.literal('ADMIN'), z.literal('USER')]).optional(),
});

userRouter.post('/', isAuthenticated, isAdmin, async (req, res) => {
  try {
    const { username, email, password, role } = req.body;
    const data = userCreateSchema.parse({ username, email, password, role });
    const updatedUser = await createUser(
      data.email,
      data.username,
      data.password,
      data.role
    );
    res.status(200).json(updatedUser);
  } catch (error: any) {
    res.status(400).json({ error: error.message });
  }
});

export default userRouter;
