import cors from 'cors';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import dotenv from 'dotenv';

dotenv.config();

// Helper to clean up URL string
const envFrontendUrl = (process.env.FRONTEND_URL || '').trim().replace(/\/$/, '');
const vercelProjectOriginRegex = /^https:\/\/tjc-autosupply(?:-[a-z0-9-]+)?\.vercel\.app$/i;

// CORS configuration
export const corsOptions = {
  origin: (origin, callback) => {
    if (!origin) return callback(null, true);

    const cleanedOrigin = String(origin).trim().replace(/\/$/, '');
    const allowedOrigins = [
      envFrontendUrl,
      'https://tjc-autosupply.vercel.app',
      'http://localhost:5173',
      'http://127.0.0.1:5173',
      'http://localhost:3000'
    ].filter(Boolean);

    if (allowedOrigins.includes(cleanedOrigin) || vercelProjectOriginRegex.test(cleanedOrigin)) {
      return callback(null, true);
    }

    return callback(new Error(`CORS blocked for origin: ${cleanedOrigin}`));
  },
  credentials: true,
  optionsSuccessStatus: 200
};

export const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, 
  max: 1000, 
  message: {
    success: false,
    message: 'Too many requests from this IP, please try again later.'
  },
  standardHeaders: true,
  legacyHeaders: false,
});

export const securityHeaders = helmet({
  contentSecurityPolicy: false,
  // --- FIX: Allow images to be loaded cross-origin ---
  crossOriginResourcePolicy: { policy: "cross-origin" },
  crossOriginOpenerPolicy: false,
  crossOriginEmbedderPolicy: false
});

export const errorHandler = (err, req, res, next) => {
  console.error(err.stack);
  res.status(err.status || 500).json({
    success: false,
    message: err.message || 'Internal Server Error',
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  });
};

export const notFound = (req, res) => {
  res.status(404).json({
    success: false,
    message: `Route ${req.originalUrl} not found`
  });
};