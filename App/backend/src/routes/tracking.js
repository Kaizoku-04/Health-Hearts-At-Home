// src/routes/tracking.js
import express from 'express';
import db from '../../data/database.js';

const trackingRouter = express.Router();

/* ======================================
   GET tracking data for a child
   GET /api/tracking/:childId
   ====================================== */
trackingRouter.get('/:childId', async (req, res, next) => {
    try {
        const { childId } = req.params;

        const result = await db.query(
            `
      SELECT
        id,
        child_id        AS "childId",
        weight,
        note,
        recorded_at     AS "recordedAt",
        created_at      AS "createdAt"
      FROM childtracking
      WHERE child_id = $1
      ORDER BY recorded_at DESC;
      `,
            [childId]
        );

        res.json(result.rows);
    } catch (err) {
        next(err);
    }
});

/* ======================================
   ADD tracking entry
   POST /api/tracking
   ====================================== */
trackingRouter.post('/', async (req, res, next) => {
    try {
        const {
            childId,
            weight,
            note,
            recordedAt,
        } = req.body;

        const result = await db.query(
            `
      INSERT INTO childtracking (
        child_id,
        weight,
        note,
        recorded_at
      )
      VALUES ($1, $2, $3, $4)
      RETURNING
        id,
        child_id   AS "childId",
        weight,
        note,
        recorded_at AS "recordedAt",
        created_at  AS "createdAt";
      `,
            [childId, weight, note, recordedAt]
        );

        res.status(201).json(result.rows[0]);
    } catch (err) {
        next(err);
    }
});


/* ======================================
   UPDATE tracking entry
   PUT /api/tracking/:id
   ====================================== */
trackingRouter.put('/:id', async (req, res, next) => {
    try {
        const { id } = req.params;
        const {
            weight,
            note,
            recordedAt,
        } = req.body;

        const result = await db.query(
            `
      UPDATE childtracking
      SET
        weight = $1,
        note = $2,
        recorded_at = $3,
        updated_at = NOW()
      WHERE id = $4
      RETURNING
        id,
        child_id   AS "childId",
        weight,
        note,
        recorded_at AS "recordedAt",
        created_at  AS "createdAt";
      `,
            [weight, note, recordedAt, id]
        );

        if (result.rowCount === 0) {
            return res.status(404).json({ message: 'Tracking entry not found' });
        }

        res.json(result.rows[0]);
    } catch (err) {
        next(err);
    }
});


/* ======================================
   DELETE tracking entry
   DELETE /api/tracking/:id
   ====================================== */
trackingRouter.delete('/:id', async (req, res, next) => {
    try {
        const { id } = req.params;

        const result = await db.query(
            `DELETE FROM childtracking WHERE id = $1`,
            [id]
        );

        if (result.rowCount === 0) {
            return res.status(404).json({ message: 'Tracking entry not found' });
        }

        res.status(204).send();
    } catch (err) {
        next(err);
    }
});


export default trackingRouter;
