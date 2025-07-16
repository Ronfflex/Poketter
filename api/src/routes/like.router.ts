import { Router } from "express";
import { prisma } from "..";

const likeRouter = Router();

likeRouter.post("/", async (req, res) => {
  try {
    if (!req.body.pokemonId) {
      throw new Error("Missing pokemonId");
    }
    const user = req.body.user;

    if (!user) {
      return res.status(401).json({ error: "Unauthorized" });
    }

    const like = await prisma.like.create({
      data: {
        pokemonId: req.body.pokemonId,
        userId: req.body.user.id,
      },
    });

    res.status(201).json(like);
  } catch (error: any) {
    res.status(400).json({ error: error.message });
  }
});

likeRouter.get("/", async (req, res) => {
  try {
    if (!req.body.user.id) {
      throw new Error("Missing user");
    }
    const userId = req.query.userId ? Number(req.query.userId) : undefined;
    const where = userId ? { userId } : { userId: req.body.user.id };

    const likes = await prisma.like.findMany({ where });
    res.json(likes);
  } catch (error: any) {
    res.status(400).json({ error: error.message });
  }
});

// DELETE /like/:pokemonId - Remove a like for the authenticated user
likeRouter.delete("/like/:pokemonId", async (req, res) => {
  try {
    const pokemonId = Number(req.params.pokemonId);
    const user = req.body.user;

    if (!user) {
      return res.status(401).json({ error: "Unauthorized" });
    }

    const deleted = await prisma.like.deleteMany({
      where: {
        pokemonId,
        userId: user.id,
      },
    });

    res.json({ deletedCount: deleted.count });
  } catch (error: any) {
    res.status(400).json({ error: error.message });
  }
});

export default likeRouter;
