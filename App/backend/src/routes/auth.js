// src/routes/auth.js
import express from 'express';
import authMiddlewareFactory from '../middlewares/auth.js';
import { sendResetLimiter } from '../rateLimiter/sendResetLimiter.js';
import * as ctrl from '../controllers/authController.js';

const authMiddleware = authMiddlewareFactory();

const router = express.Router();

// helper to forward async errors to express error handler
function wrapAsync(fn) {
    return function (req, res, next) {
        Promise.resolve(fn(req, res, next)).catch(next);
    };
}

// public
router.post('/signup', wrapAsync(ctrl.signupHandler));
router.post('/login', wrapAsync(ctrl.loginHandler));
router.post('/refresh', wrapAsync(ctrl.refreshHandler));
router.post('/google', wrapAsync(ctrl.googleHandler));

// password reset
router.post('/send-reset-code', sendResetLimiter, wrapAsync(ctrl.sendResetCodeHandler));
router.post('/verify-reset-code', wrapAsync(ctrl.verifyResetHandler));
router.post('/confirm-reset', wrapAsync(ctrl.confirmResetHandler));

// verify email (link)
router.get('/verify-email', wrapAsync(ctrl.verifyEmailHandler));

// protected
router.get('/me', authMiddleware, wrapAsync(ctrl.meHandler));
// protect logout so only authenticated users can log themselves out
router.post('/logout', authMiddleware, wrapAsync(ctrl.logoutHandler));

export default router;
