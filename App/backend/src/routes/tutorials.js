// src/routes/tutorials.js
import express from 'express';
import db from '../../data/database.js';

const tutorialsrouter = express.Router();

// GET /api/tutorials?language=en&limit=10&offset=0
tutorialsrouter.get('/', async (req, res, next) => {
    try {
        const { language } = req.query;
        let { limit, offset } = req.query;

        // Validate and sanitize pagination params
        const MAX_LIMIT = 100;
        limit = limit ? parseInt(limit, 10) : 20; // default 20
        offset = offset ? parseInt(offset, 10) : 0;

        if (Number.isNaN(limit) || Number.isNaN(offset) || limit < 1 || offset < 0) {
            return res.status(400).json({ message: 'Invalid pagination parameters' });
        }
        if (limit > MAX_LIMIT) limit = MAX_LIMIT;

        // Build dynamic SQL with parameterized values
        const values = [];
        const whereClauses = [];
        let idx = 1;

        if (language) {
            whereClauses.push(`language = $${idx++}`);
            values.push(language);
        }

        let sql = `
      SELECT
        id,
        title,
        description,
        image_url     AS "imageUrl",
        video_url     AS "videoUrl",
        external_link AS "externalLink",
        language,
        created_at
      FROM tutorials
    `;

        if (whereClauses.length) {
            sql += ' WHERE ' + whereClauses.join(' AND ');
        }

        sql += ` ORDER BY created_at DESC LIMIT $${idx++} OFFSET $${idx++};`;
        values.push(limit, offset);

        const result = await db.query(sql, values);

        // Build absolute URLs for media if they are relative paths
        const baseUrl = `${req.protocol}://${req.get('host')}`;

        const rows = result.rows.map((r) => {
            const imageUrl =
                r.imageUrl && r.imageUrl.startsWith('/')
                    ? baseUrl + r.imageUrl
                    : r.imageUrl;
            const videoUrl =
                r.videoUrl && r.videoUrl.startsWith('/')
                    ? baseUrl + r.videoUrl
                    : r.videoUrl;

            return {
                id: r.id,
                title: r.title,
                description: r.description,
                imageUrl,
                videoUrl,
                externalLink: r.externalLink,
                language: r.language,
                createdAt: r.created_at,
            };
        });

        res.json({
            count: rows.length,
            limit,
            offset,
            data: rows,
        });
    } catch (err) {
        next(err);
    }
});

export default tutorialsrouter;
