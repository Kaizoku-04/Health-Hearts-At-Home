// src/routes/spiritual.js
import express from 'express';
import db from '../../data/database.js';

const spiritualrouter = express.Router();

// GET /api/spiritual
spiritualrouter.get('/', async (req, res, next) => {
    try {
        const result = await db.query(`
            SELECT
                id,
                item_index,
                audio_url
            FROM spiritual
            ORDER BY item_index ASC;
        `);

        // Build full URL dynamically (IMPORTANT)
        const baseUrl = `${req.protocol}://${req.get('host')}`;

        const data = result.rows.map(row => ({
            id: row.id,
            index: row.item_index,
            audioUrl: baseUrl + row.audio_url
        }));

        res.json(data);
    } catch (err) {
        next(err);
    }
});

export default spiritualrouter;
