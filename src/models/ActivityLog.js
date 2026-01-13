import { getPool } from '../config/database.js';

export class ActivityLog {
  static async create({ userId, username, action, details, ipAddress }) {
    const pool = getPool();
    await pool.execute(
      `INSERT INTO activity_logs (user_id, username, action, details, ip_address, created_at) 
       VALUES (?, ?, ?, ?, ?, NOW())`,
      [userId, username, action, details, ipAddress || '::1']
    );
  }

  static async findAll(filters = {}, limit = 50, offset = 0) {
    const pool = getPool();
    let query = `SELECT * FROM activity_logs WHERE 1=1`;
    const params = [];

    if (filters.search) {
      query += ` AND (username LIKE ? OR action LIKE ? OR details LIKE ?)`;
      const term = `%${filters.search}%`;
      params.push(term, term, term);
    }
    
    if (filters.startDate) {
      query += ` AND created_at >= ?`;
      params.push(filters.startDate);
    }

    if (filters.endDate) {
      query += ` AND created_at <= ?`;
      params.push(filters.endDate);
    }

    const countQuery = query.replace('SELECT *', 'SELECT COUNT(*) as total');
    const [countResult] = await pool.execute(countQuery, params);
    
    query += ` ORDER BY created_at DESC LIMIT ? OFFSET ?`;
    params.push(parseInt(limit), parseInt(offset));
    
    const [rows] = await pool.execute(query, params);

    return {
      logs: rows,
      total: countResult[0].total
    };
  }

  // [NEW] Get total count for dashboard/settings
  static async countAll() {
    const pool = getPool();
    const [rows] = await pool.execute('SELECT COUNT(*) as total FROM activity_logs');
    return rows[0].total;
  }

  // [NEW] Delete logs older than X days
  static async prune(daysToKeep) {
    const pool = getPool();
    const [result] = await pool.execute(
      `DELETE FROM activity_logs WHERE created_at < DATE_SUB(NOW(), INTERVAL ? DAY)`,
      [parseInt(daysToKeep)]
    );
    return result.affectedRows;
  }
}