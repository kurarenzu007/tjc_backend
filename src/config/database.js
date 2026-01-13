import mysql2 from 'mysql2/promise';
import dotenv from 'dotenv';

dotenv.config();

const requiredEnv = ['DB_HOST', 'DB_PORT', 'DB_USER', 'DB_PASSWORD', 'DB_NAME'];
const missingEnv = requiredEnv.filter((key) => !process.env[key]);
if (missingEnv.length) {
  throw new Error(`Missing required environment variables: ${missingEnv.join(', ')}`);
}

const getTrimmedEnv = (key) => {
  const v = process.env[key];
  return typeof v === 'string' ? v.trim() : v;
};

const parseBooleanEnv = (value) => {
  if (value == null) return false;
  return ['1', 'true', 'yes', 'on'].includes(String(value).trim().toLowerCase());
};

const dbConfig = {
  host: getTrimmedEnv('DB_HOST'),
  port: Number(process.env.DB_PORT),
  user: getTrimmedEnv('DB_USER'),
  password: getTrimmedEnv('DB_PASSWORD'),
  database: getTrimmedEnv('DB_NAME'),
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  connectTimeout: 60000,
};

if (parseBooleanEnv(process.env.DB_SSL)) {
  dbConfig.ssl = {
    rejectUnauthorized: parseBooleanEnv(process.env.DB_SSL_REJECT_UNAUTHORIZED),
  };
}

let pool;

export const initializeDatabase = async () => {
  const maxRetries = 10;
  const retryDelay = 3000; // 3 seconds
  
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      console.log(`🔌 Database connection attempt ${attempt}/${maxRetries}...`);
      
      pool = mysql2.createPool(dbConfig);

      // Test the connection
      const connection = await pool.getConnection();
      console.log('✅ Database connected successfully');
      connection.release();

      return pool;
    } catch (error) {
      console.error(`❌ Database connection attempt ${attempt} failed:`, {
        message: error?.message,
        code: error?.code,
        errno: error?.errno,
      });

      if (attempt === maxRetries) {
        console.error('💀 Max retry attempts reached. Database connection failed permanently.');
        throw error;
      }

      console.log(`⏳ Retrying in ${retryDelay / 1000} seconds...`);
      await new Promise(resolve => setTimeout(resolve, retryDelay));
    }
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
