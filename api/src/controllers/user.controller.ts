import { User } from '@prisma/client';
import { prisma } from '../index';
import * as bcrypt from 'bcrypt';

export const selfUpdate = async (
  user: User,
  newEmail: string | undefined,
  newUsername: string | undefined,
  newPassword: string | undefined
) => {
  try {
    const updatedUser = await prisma.user.update({
      where: {
        id: user.id,
      },
      data: {
        email: newEmail,
        username: newUsername,
        password: newPassword ? await bcrypt.hash(newPassword, 10) : undefined,
      },
    });
    return { message: 'user has been updated', user: updatedUser };
  } catch (error: any) {
    throw new Error(`Something went wrong ${error.message}`);
  }
};

export const updateUser = async (
  userId: number,
  email?: string,
  username?: string,
  password?: string,
  role?: 'ADMIN' | 'USER'
) => {
  try {
    const updatedUser = await prisma.user.update({
      where: {
        id: userId,
      },
      data: {
        email: email ? email : undefined,
        username: username ? username : undefined,
        password: password ? await bcrypt.hash(password, 10) : undefined,
        role: role ? role : undefined,
      },
    });
    return { message: 'user has been updated', user: updatedUser };
  } catch (error: any) {
    throw new Error(`Something went wrong ${error.message}`);
  }
};

export const createUser = async (
  email: string,
  username: string,
  password: string,
  role?: 'ADMIN' | 'USER'
) => {
  try {
    const newUser = await prisma.user.create({
      data: {
        username: username,
        email: email,
        password: password,
        role: role,
      },
    });
    return newUser;
  } catch (error: any) {
    throw new Error(`Something went wrong ${error.message}`);
  }
};

export const deleteUser = async (userId: number) => {
  try {
    const deletedUser = await prisma.user.delete({
      where: {
        id: userId,
      },
    });
    return { message: 'user has been deleted', user: deletedUser };
  } catch (error: any) {
    throw new Error(`Something went wrong ${error.message}`);
  }
};

export const getUserById = async (userId: number) => {
  try {
    const user = await prisma.user.findUnique({
      where: {
        id: userId,
      },
    });
    if (!user) throw new Error('User not found');

    return user;
  } catch (error: any) {
    throw new Error(`Something went wrong ${error.message}`);
  }
};

export const getUserByUsername = async (username: string) => {
  try {
    const user = await prisma.user.findUnique({
      where: {
        username,
      },
    });
    if (!user) throw new Error('User not found');

    return user;
  } catch (error: any) {
    throw new Error(`Something went wrong ${error.message}`);
  }
};

export const getAllUsers = async () => {
  try {
    const users = await prisma.user.findMany();
    return users;
  } catch (error: any) {
    throw new Error(`Something went wrong ${error.message}`);
  }
};
