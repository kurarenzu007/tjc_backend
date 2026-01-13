import bcrypt from 'bcryptjs';
import mysql from 'mysql2/promise';
import dotenv from 'dotenv';

// Load env vars
dotenv.config();

const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'tjsims_db',
};

(async () => {
  console.log('🔄 Connecting to database...');
  let connection;
  try {
    connection = await mysql.createConnection(dbConfig);
    
    // 1. Generate a FRESH hash for "admin"
    const password = 'admin';
    const salt = await bcrypt.genSalt(10);
    const hash = await bcrypt.hash(password, salt);

    console.log(`🔑 Generated new hash for password '${password}'`);

    // 2. Update the users
    const usersToUpdate = [
        'admin@gmail.com',
        'manager@tjc.com', 
        'staff@tjc.com', 
        'driver@tjc.com'
    ];
    
    for (const email of usersToUpdate) {
        const [result] = await connection.execute(
            'UPDATE users SET password_hash = ?, status = ? WHERE email = ?',
            [hash, 'Active', email]
        );
        
        if (result.affectedRows > 0) {
            console.log(`✅ Updated password for: ${email}`);
        } else {
            console.log(`⚠️ User not found: ${email} (Skipping)`);
        }
    }

    console.log('\n🎉 Password reset complete! You can now log in with "admin".');

  } catch (err) {
    console.error('❌ Error:', err.message);
  } finally {
    if (connection) await connection.end();
    process.exit(0);
  }
})();