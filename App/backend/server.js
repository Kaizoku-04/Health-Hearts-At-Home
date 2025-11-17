// server.js
import 'dotenv/config';           // loads .env into process.env (optional but recommended)
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';      // small security improvement (optional)
import routes from './src/routes.js'; // <-- main aggregator from the refactor
import db from './data/database.js';

const app = express();

// Basic middleware
app.use(helmet());
app.use(cors());      // DEV: allow all origins. In prod restrict origins.
app.use(express.json());

// Mount the refactored routes. I kept the same paths so existing clients don't need changes.
app.use('/', routes);

// generic error handler (put before app.listen)
app.use((err, req, res, next) => {
    console.error('Unhandled error:', err);
    // don't leak internals in production
    const msg = process.env.NODE_ENV === 'production' ? 'Internal server error' : err.message || 'Internal server error';
    res.status(err.status || 500).json({ message: msg });
});

// Prefer binding to 0.0.0.0 for access from other machines on the LAN
const PORT = process.env.PORT || 4000;
const HOST = process.env.HOST || '0.0.0.0';

async function start() {
    try {
        // ensure schema (dev convenience). In prod you might set DB_INIT=false and run migrations instead.
        await db.init();

        app.listen(PORT, HOST, () => {
            console.log(`Auth server running on http://${HOST}:${PORT}`);
        });
    } catch (err) {
        console.error('Failed to start server due to DB error:', err);
        process.exit(1);
    }
}

start();
