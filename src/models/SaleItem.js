import { getPool } from '../config/database.js';

export class SaleItem {
  static async findBySaleId(saleId) {
    const pool = getPool();
    const [rows] = await pool.execute(
      'SELECT * FROM sale_items WHERE sale_id = ? ORDER BY id',
      [saleId]
    );
    return rows;
  }

  static async findById(id) {
    const pool = getPool();
    const [rows] = await pool.execute(
      'SELECT * FROM sale_items WHERE id = ?',
      [id]
    );
    return rows[0] || null;
  }

  // [UPDATED] Now saves serial_numbers
  static async create(saleItemData) {
    const pool = getPool();
    const {
      sale_id,
      product_id,
      product_name,
      brand,
      price,
      quantity,
      subtotal,
      serialNumbers // Extract serial numbers
    } = saleItemData;

    // Prepare serial numbers as JSON string (or null if empty)
    const serialsJson = (serialNumbers && serialNumbers.length > 0) 
      ? JSON.stringify(serialNumbers) 
      : null;

    const [result] = await pool.execute(
      `INSERT INTO sale_items (sale_id, product_id, product_name, brand, price, quantity, subtotal, serial_numbers)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [sale_id, product_id, product_name, brand, price, quantity, subtotal, serialsJson]
    );

    return result.insertId;
  }

  static async update(id, saleItemData) {
    const pool = getPool();
    const {
      product_name,
      brand,
      price,
      quantity,
      subtotal
    } = saleItemData;

    const updates = [];
    const params = [];

    if (product_name !== undefined) {
      updates.push('product_name = ?');
      params.push(product_name);
    }
    if (brand !== undefined) {
      updates.push('brand = ?');
      params.push(brand);
    }
    if (price !== undefined) {
      updates.push('price = ?');
      params.push(price);
    }
    if (quantity !== undefined) {
      updates.push('quantity = ?');
      params.push(quantity);
    }
    if (subtotal !== undefined) {
      updates.push('subtotal = ?');
      params.push(subtotal);
    }

    if (updates.length === 0) {
      throw new Error('No fields to update');
    }

    params.push(id);

    const query = `UPDATE sale_items SET ${updates.join(', ')} WHERE id = ?`;
    const [result] = await pool.execute(query, params);

    return result.affectedRows > 0;
  }

  static async delete(id) {
    const pool = getPool();
    const [result] = await pool.execute(
      'DELETE FROM sale_items WHERE id = ?',
      [id]
    );
    return result.affectedRows > 0;
  }

  static async deleteBySaleId(saleId) {
    const pool = getPool();
    const [result] = await pool.execute(
      'DELETE FROM sale_items WHERE sale_id = ?',
      [saleId]
    );
    return result.affectedRows > 0;
  }
}