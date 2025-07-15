import { User } from '@prisma/client';
import { prisma } from '../index';
import * as bcrypt from 'bcrypt';
import { sign, verify } from 'jsonwebtoken';

export const fetchSession = async (authToken: string): Promise<User> => {
  try {
    const decoded = verify(authToken, process.env.JWT_SECRET!);
    const { id } = decoded as { id: number };

    const user = await prisma.user.findUnique({
      where: {
        id,
      },
    });

    if (!user) throw new Error('User not found');
    return user;
  } catch (error: any) {
    throw new Error(`Something went wrong ${error.message}`);
  }
};

export const logout = async (authToken: string) => {
  try {
    const decoded = verify(authToken, process.env.JWT_SECRET!);
    const { id } = decoded as { id: number };
    const user = await prisma.user.update({
      where: {
        id,
      },
      data: {
        authToken: null,
      },
    });
    if (!user) throw new Error('User not found');

    return user;
  } catch (error: any) {
    throw new Error(`Something went wrong ${error.message}`);
  }
};

export const login = async (username: string, password: string) => {
  try {
    const user = await prisma.user.findUnique({
      where: {
        username,
      },
    });
    if (!user) throw new Error('User not found');
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) throw new Error('Invalid password');

    const token = sign({ id: user.id }, process.env.JWT_SECRET!, {
      expiresIn: '4h',
    });

    const userUpdatedWithJWT = await prisma.user.update({
      where: {
        id: user.id,
      },
      data: {
        authToken: token,
      },
    });
    if (!userUpdatedWithJWT) throw new Error('Error updating user with JWT');
    return userUpdatedWithJWT;
  } catch (error: any) {
    throw new Error(`Something went wrong: ${error.message}`);
  }
};

export const register = async (
  username: string,
  password: string,
  email: string
) => {
  try {
    const userExists = await prisma.user.findUnique({
      where: {
        username,
      },
    });
    const emailExists = await prisma.user.findUnique({
      where: {
        email,
      },
    });
    if (userExists) throw new Error('Username already exists');
    if (emailExists) throw new Error('Email already used');

    const hashedPassword = bcrypt.hash(password, 10);
    const user = await prisma.user.create({
      data: {
        username,
        password: await hashedPassword,
        email,
      },
    });

    return user;
  } catch (error: any) {
    throw new Error(`Something went wrong: ${error.message}`);
  }
};
