import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';
import { initializeDatabase, closeDatabase } from './config/database.js';
import { corsOptions, limiter, securityHeaders, errorHandler, notFound } from './middleware/index.js';
import { Product } from './models/Product.js';
import apiRoutes from './routes/index.js';

dotenv.config();

// --- FIX: Define __dirname for ES Modules ---
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
// --------------------------------------------

const app = express();
const PORT = process.env.PORT || 5000;

let server;

const gracefulShutdown = async (signal) => {
  console.log(`\n🛑 Received ${signal}. Starting graceful shutdown...`);
  try {
    if (server) {
      server.close(() => {
        console.log('✅ HTTP server closed');
      });
    }
    await closeDatabase();
    console.log('✅ Graceful shutdown completed');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error during graceful shutdown:', error);
    process.exit(1);
  }
};

process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
process.on('SIGINT', () => gracefulShutdown('SIGINT'));

app.use(securityHeaders);
app.use(cors(corsOptions));
app.use(limiter);
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// --- FIX: Serve Uploads using Absolute Path ---
// This ensures it works regardless of where you start the server from
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));
// ----------------------------------------------

app.get('/health', (req, res) => {
  res.json({
    success: true,
    message: 'TJ Sims API is running',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development'
  });
});

app.use('/api', apiRoutes);
app.use('*', notFound);
app.use(errorHandler);

const startServer = async () => {
  try {
    await initializeDatabase();
    // Optional: Seed data if needed
    // await Product.seedSampleData();

    server = app.listen(PORT, () => {
      console.log(`
🚀 TJ Sims Backend Server Started Successfully!
📡 Server running on: http://localhost:${PORT}
📂 Static Files: ${path.join(__dirname, 'uploads')}
🌍 Environment: ${process.env.NODE_ENV || 'development'}
      `);
    });

  } catch (error) {
    console.error('❌ Failed to start server:', error);
    process.exit(1);
  }
};

process.on('unhandledRejection', (err) => {
  console.error('Unhandled Promise Rejection:', err.message);
  gracefulShutdown('UNHANDLED_REJECTION');
});

process.on('uncaughtException', (err) => {
  console.error('Uncaught Exception:', err.message);
  gracefulShutdown('UNCAUGHT_EXCEPTION');
});

startServer();

export default app;