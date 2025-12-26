// server.js
import 'dotenv/config';
import path from 'path';
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import { fileURLToPath } from 'url';

import routes from './src/routes.js';
import tutorialsrouter from './src/routes/tutorials.js';
import spiritualrouter from './src/routes/spiritual.js';
import db from './data/database.js';
import trackingRouter from './src/routes/tracking.js';
import childrenRouter from './src/routes/children.js';


// emulate __dirname in ES modules
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();

/* ================================
   BASIC MIDDLEWARE
   ================================ */
app.use(helmet());
app.use(cors());              // DEV: allow all origins
app.use(express.json());

/* ================================
   MEDIA RANGE SUPPORT (IMPORTANT)
   ================================ */
app.use((req, res, next) => {
    if (req.method === 'GET') {
        res.setHeader('Accept-Ranges', 'bytes');
    }
    next();
});

/* ================================
   SERVE MEDIA FOLDER
   ================================ */

// App/
// ├─ backend/
// └─ media/
app.use(
    '/media',
    express.static(path.join(__dirname, '..', 'media'), {
        setHeaders: (res, filePath) => {
            // enforce correct streaming behavior for audio/video
            if (/\.(mp3|mp4|m4a|wav|ogg)$/i.test(filePath)) {
                res.setHeader('Accept-Ranges', 'bytes');
            }
        },
    })
);

/* ================================
   ROUTES
   ================================ */
app.use('/', routes);
app.use('/api/tutorials', tutorialsrouter);
app.use('/api/spiritual', spiritualrouter);
app.use('/api/children', childrenRouter);
app.use('/api/tracking', trackingRouter);

/* ================================
   ERROR HANDLER
   ================================ */
app.use((err, req, res, next) => {
    console.error('Unhandled error:', err);
    const msg =
        process.env.NODE_ENV === 'production'
            ? 'Internal server error'
            : err.message || 'Internal server error';

    res.status(err.status || 500).json({ message: msg });
});

/* ================================
   SERVER BOOT
   ================================ */
const PORT = process.env.PORT || 4000;
const HOST = process.env.HOST || '0.0.0.0';

async function start() {
    try {
        await db.init();

        app.listen(PORT, HOST, () => {
            console.log(`Server running on http://${HOST}:${PORT}`);
            console.log(`Media root available at http://${HOST}:${PORT}/media`);
            console.log(`Tutorial images: /media/tutorials/{ar|en}/images`);
            console.log(`Tutorial videos: /media/tutorials/{ar|en}/videos`);
        });
    } catch (err) {
        console.error('Failed to start server due to DB error:', err);
        process.exit(1);
    }
}

start();
