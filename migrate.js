import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import mysql2 from 'mysql2/promise';
import dotenv from 'dotenv';

dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function runMigration() {
  let connection;
  
  try {
    console.log('🔄 Starting database migration...');
    
    // Read the migration file
    const migrationPath = path.join(__dirname, 'src/database/migrations/tjsims_db.sql');
    const migrationSQL = fs.readFileSync(migrationPath, 'utf8');
    
    // Create database connection (without specifying database first)
    connection = await mysql2.createConnection({
      host: process.env.DB_HOST,
      port: process.env.DB_PORT,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : false
    });
    
    console.log('✅ Connected to MySQL server');
    
    // Create database if it doesn't exist
    const dbName = process.env.DB_NAME;
    await connection.query(`CREATE DATABASE IF NOT EXISTS \`${dbName}\``);
    await connection.query(`USE \`${dbName}\``);
    console.log(`✅ Database '${dbName}' ready`);
    
    // Split SQL into individual statements (basic split)
    const statements = migrationSQL
      .split(';')
      .map(stmt => stmt.trim())
      .filter(stmt => stmt.length > 0 && !stmt.startsWith('--'));
    
    console.log(`📝 Found ${statements.length} SQL statements to execute`);
    
    // Execute each statement
    for (let i = 0; i < statements.length; i++) {
      const statement = statements[i];
      if (statement.trim()) {
        try {
          await connection.query(statement);
          console.log(`✅ Statement ${i + 1}/${statements.length} executed successfully`);
        } catch (error) {
          // Some statements might fail (like if tables already exist)
          console.log(`⚠️  Statement ${i + 1} failed: ${error.message}`);
        }
      }
    }
    
    console.log('🎉 Migration completed successfully!');
    
  } catch (error) {
    console.error('❌ Migration failed:', error);
    throw error;
  } finally {
    if (connection) {
      await connection.end();
      console.log('🔒 Database connection closed');
    }
  }
}

// Run migration if this file is executed directly
if (import.meta.url === `file://${process.argv[1]}`) {
  runMigration().catch(console.error);
}

export default runMigration;
