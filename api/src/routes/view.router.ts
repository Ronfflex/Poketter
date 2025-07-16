import { Router } from "express";
import { z } from "zod";
import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();
const viewRouter = Router();

viewRouter.post("/", async (req, res) => {
  try {
    const bodySchema = z.object({
      pokemonId: z.number(),
    });
    const { pokemonId } = bodySchema.parse(req.body);
    const user = req.body.user;

    if (!user) {
      return res.status(401).json({ error: "Unauthorized" });
    }

    const view = await prisma.vue.create({
      data: {
        pokemonId,
        userId: user.id,
      },
    });

    res.status(201).json(view);
  } catch (error: any) {
    res.status(400).json({ error: error.message });
  }
});

viewRouter.get("/", async (req, res) => {
  try {
    const userId = req.query.userId ? Number(req.query.userId) : undefined;
    const where = userId ? { userId } : {};

    const views = await prisma.vue.findMany({ where });
    res.json(views);
  } catch (error: any) {
    res.status(400).json({ error: error.message });
  }
});

export default viewRouter;
