import mysql2 from 'mysql2/promise';
import dotenv from 'dotenv';

dotenv.config();

const requiredEnv = ['DB_HOST', 'DB_PORT', 'DB_USER', 'DB_PASSWORD', 'DB_NAME'];
const missingEnv = requiredEnv.filter((key) => !process.env[key]);
if (missingEnv.length) {
  throw new Error(`Missing required environment variables: ${missingEnv.join(', ')}`);
}

const parseBooleanEnv = (value) => {
  if (value == null) return false;
  return ['1', 'true', 'yes', 'on'].includes(String(value).trim().toLowerCase());
};

const dbConfig = {
  host: process.env.DB_HOST,
  port: Number(process.env.DB_PORT),
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  acquireTimeout: 60000,
  timeout: 60000,
};

if (parseBooleanEnv(process.env.DB_SSL)) {
  dbConfig.ssl = {
    rejectUnauthorized: parseBooleanEnv(process.env.DB_SSL_REJECT_UNAUTHORIZED),
  };
}

let pool;

export const initializeDatabase = async () => {
  try {
    pool = mysql2.createPool(dbConfig);

    // Test the connection
    const connection = await pool.getConnection();
    console.log('✅ Database connected successfully');
    connection.release();

    return pool;
  } catch (error) {
    console.error('❌ Database connection failed:', error.message);
    throw error;
  }
};

export const getPool = () => {
  if (!pool) {
    throw new Error('Database not initialized. Call initializeDatabase() first.');
  }
  return pool;
};

// Graceful shutdown
export const closeDatabase = async () => {
  if (pool) {
    await pool.end();
    console.log('🔒 Database connection closed');
  }
};
