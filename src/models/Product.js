import { getPool } from '../config/database.js';

export class Product {
  static async create(productData) {
    const pool = getPool();
    const {
      name, brand, category, price, status, description,
      vehicle_compatibility, image, requires_serial, unit_tag // [FIX] Added unit_tag
    } = productData;

    const [maxIdResult] = await pool.execute('SELECT MAX(id) as maxId FROM products');
    const nextId = (maxIdResult[0].maxId || 0) + 1;
    const productId = `P${nextId.toString().padStart(3, '0')}`;

    // [FIX] Added unit_tag to INSERT
    const [result] = await pool.execute(
      `INSERT INTO products (
        product_id, name, brand, category, vehicle_compatibility, 
        price, unit_tag, status, description, image, 
        requires_serial, created_at, updated_at
       ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())`,
      [
        productId, name, brand, category, vehicle_compatibility || null, 
        price, unit_tag || 'EA', status, description, image, 
        requires_serial ? 1 : 0
      ]
    );
    return result.insertId;
  }

  static async findAll(filters = {}, limit = 10, offset = 0) {
    const pool = getPool();
    
    let whereClause = ' WHERE 1=1';
    let params = [];
    // [FIX] Added unit to filters
    const { search, category, brand, status, unit } = filters;

    if (search) {
      whereClause += ' AND (name LIKE ? OR product_id LIKE ? OR brand LIKE ?)';
      params.push(`%${search}%`, `%${search}%`, `%${search}%`);
    }
    if (category && category !== 'All Categories') {
      whereClause += ' AND category = ?';
      params.push(category);
    }
    if (brand && brand !== 'All Brand') {
      whereClause += ' AND brand = ?';
      params.push(brand);
    }
    if (status && status !== 'All Status') {
      whereClause += ' AND status = ?';
      params.push(status);
    }
    // [FIX] Added Unit Filter Logic
    if (unit && unit !== 'All Units') {
      whereClause += ' AND unit_tag = ?';
      params.push(unit);
    }

    // [FIX] Subquery to get live inventory stock
    const quantitySubquery = `(SELECT COALESCE(SUM(stock), 0) FROM inventory WHERE product_id = products.product_id)`;

    const dataQuery = `
      SELECT products.*, 
      ${quantitySubquery} as quantity 
      FROM products 
      ${whereClause} 
      ORDER BY created_at DESC 
      LIMIT ? OFFSET ?
    `;
    
    const dataParams = [...params, parseInt(limit), parseInt(offset)];
    const countQuery = `SELECT COUNT(*) as total FROM products ${whereClause}`;

    const [rows] = await pool.execute(dataQuery, dataParams);
    const [countResult] = await pool.execute(countQuery, params);

    return {
      products: rows,
      total: countResult[0].total
    };
  }

  static async findById(id) {
    const pool = getPool();
    // [FIX] Added stock subquery here too
    const quantitySubquery = `(SELECT COALESCE(SUM(stock), 0) FROM inventory WHERE product_id = products.product_id)`;
    
    const [rows] = await pool.execute(
      `SELECT products.*, ${quantitySubquery} as quantity FROM products WHERE product_id = ? OR id = ?`,
      [id, id]
    );
    return rows[0] || null;
  }

  static async update(id, productData) {
    const pool = getPool();
    const {
      name, brand, category, price, status, description,
      vehicle_compatibility, image, requires_serial, unit_tag // [FIX] Added unit_tag
    } = productData;

    const updates = [];
    const params = [];

    if (name !== undefined) { updates.push('name = ?'); params.push(name); }
    if (brand !== undefined) { updates.push('brand = ?'); params.push(brand); }
    if (category !== undefined) { updates.push('category = ?'); params.push(category); }
    if (vehicle_compatibility !== undefined) { updates.push('vehicle_compatibility = ?'); params.push(vehicle_compatibility || null); }
    if (price !== undefined) { updates.push('price = ?'); params.push(price); }
    
    // [FIX] Added unit_tag update logic
    if (unit_tag !== undefined) { updates.push('unit_tag = ?'); params.push(unit_tag); }
    
    if (status !== undefined) { updates.push('status = ?'); params.push(status); }
    if (description !== undefined) { updates.push('description = ?'); params.push(description); }
    if (image !== undefined) { updates.push('image = ?'); params.push(image); }
    if (requires_serial !== undefined) { updates.push('requires_serial = ?'); params.push(requires_serial ? 1 : 0); }

    if (updates.length === 0) throw new Error('No fields to update');

    params.push(id);
    // Supports updating by ID or product_id string
    const query = `UPDATE products SET ${updates.join(', ')}, updated_at = NOW() WHERE product_id = ? OR id = ?`;
    // Push ID twice for the WHERE clause
    params.push(id); 
    
    const [result] = await pool.execute(query, params);
    return result.affectedRows > 0;
  }

  static async delete(id) {
    const pool = getPool();
    const [prodRows] = await pool.execute('SELECT product_id FROM products WHERE id = ? OR product_id = ?', [id, id]);
    if (prodRows.length === 0) return false;
    const productId = prodRows[0].product_id;

    const [refRows] = await pool.execute('SELECT COUNT(*) as cnt FROM sale_items WHERE product_id = ?', [productId]);
    if ((refRows[0]?.cnt || 0) > 0) {
      const err = new Error('PRODUCT_IN_USE');
      err.code = 'PRODUCT_IN_USE';
      throw err;
    }
    const [result] = await pool.execute('DELETE FROM products WHERE id = ? OR product_id = ?', [id, id]);
    return result.affectedRows > 0;
  }
  
  static async hasSerialNumbers(productId) {
    const pool = getPool();
    // Check for any serials that imply the product was once serialized and used
    const [rows] = await pool.execute(
      'SELECT COUNT(*) as count FROM serial_numbers WHERE product_id = ? AND status IN ("sold", "defective")',
      [productId]
    );
    return rows[0].count > 0;
  }
  
  static async getCategories() {
    const pool = getPool();
    const [rows] = await pool.execute('SELECT DISTINCT category FROM products ORDER BY category');
    return rows.map(row => row.category);
  }

  static async getBrands() {
    const pool = getPool();
    const [rows] = await pool.execute('SELECT name FROM brands ORDER BY name');
    return rows.map(row => row.name);
  }
}