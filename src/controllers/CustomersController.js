import { getPool } from '../config/database.js';

export class CustomersController {
  static async list(req, res) {
    try {
      const { search } = req.query;
      const pool = getPool();

      // [FIX] Select landmark so it auto-fills in Sales Page
      // [FIX] added LIMIT 20 for performance (Server-Side Filtering)
      let query = `
        SELECT DISTINCT customer_name, contact, address, landmark
        FROM sales
        WHERE customer_name IS NOT NULL AND customer_name <> ''
      `;
      const params = [];

      if (search) {
        const like = `%${search}%`;
        query += ' AND (customer_name LIKE ? OR contact LIKE ?)';
        params.push(like, like);
      }

      // Industrial Standard: Always limit results to prevent browser lag
      query += ' ORDER BY customer_name ASC LIMIT 20';

      const [rows] = await pool.execute(query, params);

      res.json({
        success: true,
        data: rows
      });
    } catch (error) {
      console.error('List customers error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to fetch customers'
      });
    }
  }
}