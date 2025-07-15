import { NextFunction } from 'express';
import { Request, Response } from 'express';
import { fetchSession } from '../controllers/auth.controller';

export async function isAuthenticated(
  req: Request,
  res: Response,
  next: NextFunction
) {
  const { authorization } = req.headers;

  try {
    if (!authorization) {
      res.status(401);
      throw new Error('🚫 Un-Authorized, you need a bearer token 🚫');
    }
    const token = authorization.split(' ')[1];
    const user = await fetchSession(token);
    req.body.user = user;
  } catch (err: any) {
    res.status(401).json({ error: err.message });
  }

  return next();
}

export async function isAdmin(req: Request, res: Response, next: NextFunction) {
  //To call this, you need to call isAuthenticated first
  const { role } = req.body.user;

  try {
    if (role === 'USER')
      throw new Error('🚫 Un-Authorized, you need to be an admin 🚫');
  } catch (err: any) {
    res.status(401).json({ error: err.message });
  }

  return next();
}
