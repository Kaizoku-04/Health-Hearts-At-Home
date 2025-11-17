// src/routes.js
import express from 'express';
import authRouter from './routes/auth.js';

const router = express.Router();

// mount auth router at root so that endpoints remain identical to your original:
// e.g. POST /signup, POST /login, POST /send-reset-code, POST /api/checkout, ...
router.use('/', authRouter);

export default router;
