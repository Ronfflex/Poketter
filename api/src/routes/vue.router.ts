import { Router } from "express";
import { z } from "zod";
import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();
const vueRouter = Router();

vueRouter.post("/", async (req, res) => {
  try {
    const bodySchema = z.object({
      pokemonId: z.number(),
    });
    const { pokemonId } = bodySchema.parse(req.body);
    const user = req.body.user;

    if (!user) {
      return res.status(401).json({ error: "Unauthorized" });
    }

    const vue = await prisma.vue.create({
      data: {
        pokemonId,
        userId: user.id,
      },
    });

    res.status(201).json(vue);
  } catch (error: any) {
    res.status(400).json({ error: error.message });
  }
});

vueRouter.get("/", async (req, res) => {
  try {
    const userId = req.query.userId ? Number(req.query.userId) : undefined;
    const where = userId ? { userId } : {};

    const vues = await prisma.vue.findMany({ where });
    res.json(vues);
  } catch (error: any) {
    res.status(400).json({ error: error.message });
  }
});

export default vueRouter;
