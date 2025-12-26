// src/routes/children.js
import express from 'express';
import db from '../../data/database.js';

const childrenRouter = express.Router();

/* ======================================
   GET all children
   GET /api/children
   ====================================== */
childrenRouter.get('/', async (req, res, next) => {
    try {
        const result = await db.query(
            `
            SELECT
              id,
              name,
              date_of_birth AS "dateOfBirth",
              gender,
              created_at AS "createdAt"
            FROM children
            ORDER BY created_at DESC;
            `
        );

        res.json(result.rows);
    } catch (err) {
        next(err);
    }
});

export default childrenRouter;
