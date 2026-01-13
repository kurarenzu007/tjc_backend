import { getPool } from '../config/database.js';

export class Inventory {
  static async findByProductId(productId) {
    const pool = getPool();
    const [rows] = await pool.execute(
      `SELECT i.*, s.name as supplier_name 
       FROM inventory i 
       LEFT JOIN suppliers s ON i.supplier_id = s.id 
       WHERE i.product_id = ?`,
      [productId]
    );
    return rows[0];
  }

  static async updateStock(productId, quantity, reorderPoint = null, options = {}) {
    const pool = getPool();
    const connection = await pool.getConnection();

    try {
      await connection.beginTransaction();

      const [productExists] = await connection.execute(
        'SELECT product_id FROM products WHERE product_id = ?',
        [productId]
      );

      if (!productExists[0]) {
        throw new Error(`Product ${productId} not found`);
      }

      const [inventory] = await connection.execute(
        'SELECT * FROM inventory WHERE product_id = ?',
        [productId]
      );

      let inventoryId;
      
      if (!inventory[0]) {
        const [result] = await connection.execute(
          `INSERT INTO inventory (product_id, stock, reorder_point)
           VALUES (?, ?, ?)`,
          [productId, Math.max(0, quantity), reorderPoint || 10]
        );
        inventoryId = result.insertId;
      } else {
        const newStock = Math.max(0, inventory[0].stock + quantity);
        const updates = [`stock = ?`, `reorder_point = COALESCE(?, reorder_point)`];
        const params = [newStock, reorderPoint];
        if (options.supplierId) { updates.push(`supplier_id = ?`); params.push(options.supplierId); }
        if (options.transactionDate) { updates.push(`last_restock_date = ?`); params.push(new Date(options.transactionDate)); }
        params.push(productId);
        await connection.execute(
          `UPDATE inventory 
           SET ${updates.join(', ')}
           WHERE product_id = ?`,
          params
        );
        inventoryId = inventory[0].id;
      }

      const transactionId = `TRX-${Date.now()}-${Math.floor(Math.random() * 1000)}`;
      const createdBy = options.createdBy || 'System';
      const txnDate = options.transactionDate ? new Date(options.transactionDate) : new Date();
      const notes = options.notes || 'Stock update through admin interface';
      
      await connection.execute(
        `INSERT INTO inventory_transactions (
           transaction_id, inventory_id, product_id, transaction_type,
           quantity, notes, transaction_date, created_by
         ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
        [
          transactionId, inventoryId, productId,
          quantity > 0 ? 'in' : 'out',
          Math.abs(quantity), notes, txnDate, createdBy
        ]
      );

      await connection.commit();
      return true;
    } catch (error) {
      await connection.rollback();
      throw error;
    } finally {
      connection.release();
    }
  }

  static async getStats() {
    const pool = getPool();
    const [rows] = await pool.execute(`
      SELECT 
        COUNT(DISTINCT i.product_id) as totalProducts,
        SUM(CASE WHEN i.stock > i.reorder_point THEN 1 ELSE 0 END) as inStock,
        SUM(CASE 
          WHEN i.stock <= i.reorder_point AND i.stock > 0 THEN 1 
          ELSE 0 
        END) as lowStock,
        SUM(CASE WHEN i.stock = 0 THEN 1 ELSE 0 END) as outOfStock
      FROM inventory i
    `);
    return rows[0];
  }

  static async getProductsWithInventory(filters = {}) {
    const pool = getPool();
    let query = `
      SELECT 
        p.*,
        COALESCE(i.stock, 0) as stock,
        COALESCE(i.reorder_point, 10) as reorder_point,
        s.name as supplier_name
      FROM products p
      LEFT JOIN inventory i ON p.product_id = i.product_id
      LEFT JOIN suppliers s ON i.supplier_id = s.id
      WHERE 1=1
      AND p.status = 'Active'
    `;
    
    const params = [];

    if (filters.search) {
      query += ' AND (p.name LIKE ? OR p.product_id LIKE ? OR p.brand LIKE ?)';
      const searchTerm = `%${filters.search}%`;
      params.push(searchTerm, searchTerm, searchTerm);
    }

    if (filters.category) {
      query += ' AND p.category = ?';
      params.push(filters.category);
    }

    // [NEW] Filter by Product Type
    if (filters.type) {
        if (filters.type === 'Serialized') {
            query += ' AND p.requires_serial = 1';
        } else if (filters.type === 'Standard') {
            query += ' AND p.requires_serial = 0';
        }
    }

    if (filters.stockStatus) {
      switch (filters.stockStatus) {
        case 'In Stock':
          query += ' AND COALESCE(i.stock, 0) > COALESCE(i.reorder_point, 10)';
          break;
        case 'Low Stock': 
          query += ' AND COALESCE(i.stock, 0) <= COALESCE(i.reorder_point, 10) AND COALESCE(i.stock, 0) > 0';
          break;
        case 'Out of Stock':
          query += ' AND (i.stock = 0 OR i.stock IS NULL)';
          break;
      }
    }

    query += ' ORDER BY p.created_at DESC';

    const [rows] = await pool.execute(query, params);
    return rows;
  }

  // Bulk Stock In
  static async bulkStockIn({ supplier, receivedBy, receivedDate, products }) {
    const pool = getPool();
    const connection = await pool.getConnection();

    try {
      await connection.beginTransaction();

      const transactionDate = receivedDate ? new Date(receivedDate) : new Date();
      const notes = `Bulk Stock In - Supplier: ${supplier} | Received by: ${receivedBy}`;

      for (const product of products) {
        const { productId, quantity } = product;
        const serialNumbers = product.serialNumbers || (product.serialNumber ? [product.serialNumber] : []);

        if (!productId || !quantity || quantity <= 0) {
          throw new Error(`Invalid product data: productId=${productId}, quantity=${quantity}`);
        }

        // 1. Verify Product
        const [productExists] = await connection.execute(
          'SELECT product_id, requires_serial FROM products WHERE product_id = ?',
          [productId]
        );

        if (!productExists[0]) {
          throw new Error(`Product ${productId} not found`);
        }

        // 2. Insert Serial Numbers
        if (productExists[0].requires_serial && serialNumbers.length > 0) {
            if (serialNumbers.length !== parseInt(quantity)) {
                throw new Error(`Quantity mismatch for ${productId}. Qty: ${quantity}, Serials scanned: ${serialNumbers.length}`);
            }

            for (const sn of serialNumbers) {
                const [existing] = await connection.execute(
                    'SELECT id FROM serial_numbers WHERE serial_number = ? AND product_id = ?',
                    [sn, productId]
                );
                
                if (existing.length > 0) {
                    throw new Error(`Serial number ${sn} already exists for product ${productId}`);
                }

                await connection.execute(
                    `INSERT INTO serial_numbers (serial_number, product_id, status, supplier_id, created_at)
                     VALUES (?, ?, 'available', ?, ?)`,
                    [sn, productId, supplier, transactionDate]
                );
            }
        }

        // 3. Update Inventory Count
        const [inventory] = await connection.execute(
          'SELECT * FROM inventory WHERE product_id = ?',
          [productId]
        );

        let inventoryId;

        if (!inventory[0]) {
          const [result] = await connection.execute(
            `INSERT INTO inventory (product_id, stock, reorder_point, last_restock_date, supplier_id)
             VALUES (?, ?, 10, ?, ?)`,
            [productId, quantity, transactionDate, supplier]
          );
          inventoryId = result.insertId;
        } else {
          const newStock = inventory[0].stock + quantity;
          await connection.execute(
            `UPDATE inventory 
             SET stock = ?, last_restock_date = ?
             WHERE product_id = ?`,
            [newStock, transactionDate, productId]
          );
          inventoryId = inventory[0].id;
        }

        // 4. Create Transaction Record
        const transactionId = `TRX-${Date.now()}-${Math.floor(Math.random() * 10000)}`;
        const serialsLog = serialNumbers.length > 0 ? serialNumbers.join(', ') : null;

        await connection.execute(
          `INSERT INTO inventory_transactions (
             transaction_id, inventory_id, product_id, transaction_type,
             quantity, serial_number, notes, transaction_date, created_by
           ) VALUES (?, ?, ?, 'in', ?, ?, ?, ?, ?)`,
          [
            transactionId, inventoryId, productId,
            quantity, serialsLog, notes, transactionDate, receivedBy
          ]
        );
      }

      await connection.commit();
      return true;
    } catch (error) {
      await connection.rollback();
      throw error;
    } finally {
      connection.release();
    }
  }

  // --- UPDATED METHOD: returnToSupplier ---
  static async returnToSupplier({ supplier, returnedBy, returnDate, products, reason }) {
    const pool = getPool();
    const connection = await pool.getConnection();

    try {
      await connection.beginTransaction();

      const transactionDate = returnDate ? new Date(returnDate) : new Date();

      for (const product of products) {
        const { productId, quantity } = product;
        const serialNumbers = product.serialNumbers || (product.serialNumber ? [product.serialNumber] : []);

        // 1. Verify Product & Inventory Record
        const [inventory] = await connection.execute(
          'SELECT * FROM inventory WHERE product_id = ?',
          [productId]
        );

        if (!inventory[0]) {
          throw new Error(`No inventory record found for product ${productId}`);
        }

        const inventoryId = inventory[0].id;
        let deductibleQuantity = 0;
        let serialsString = 'N/A';

        // 2. Handle Serial Numbers logic
        if (serialNumbers.length > 0) {
            const validSerials = serialNumbers.filter(s => s && s.trim() !== '');
            serialsString = validSerials.join(', ');

            for (const serial of validSerials) {
              const [existingSerial] = await connection.execute(
                'SELECT id, status, supplier_id FROM serial_numbers WHERE serial_number = ? AND product_id = ?',
                [serial, productId]
              );

              if (existingSerial.length === 0) {
                throw new Error(`Serial number ${serial} not found for product ${productId}`);
              }

              const serialRecord = existingSerial[0];

              // [NEW] VALIDATION: Check if this serial belongs to the selected supplier
              if (serialRecord.supplier_id && String(serialRecord.supplier_id) !== String(supplier)) {
                  // Fetch supplier names for a better error message
                  const [actualSupplier] = await connection.execute('SELECT name FROM suppliers WHERE id = ?', [serialRecord.supplier_id]);
                  const actualName = actualSupplier[0] ? actualSupplier[0].name : 'Another Supplier';
                  
                  throw new Error(`Serial ${serial} was bought from "${actualName}", not the selected supplier.`);
              }

              const currentStatus = serialRecord.status;

              if (currentStatus === 'available') {
                  deductibleQuantity++; 
              } else if (['defective', 'returned'].includes(currentStatus)) {
                  // Do nothing to deductibleQuantity
              } else {
                  throw new Error(`Serial number ${serial} has status '${currentStatus}' and cannot be returned to supplier.`);
              }

              // Update serial status to indicate it left the building
              await connection.execute(
                `UPDATE serial_numbers 
                 SET status = 'returned_to_supplier', notes = ?, updated_at = CURRENT_TIMESTAMP
                 WHERE serial_number = ?`,
                [`Returned to Supplier ID: ${supplier}. Reason: ${reason}`, serial]
              );
            }
        } else {
            // Non-serialized item: assume all come from Available Stock
            deductibleQuantity = quantity;
        }

        // 3. Update Inventory Stock (only deduct what was actually in stock)
        if (deductibleQuantity > 0) {
            if (inventory[0].stock < deductibleQuantity) {
               throw new Error(`Insufficient sellable stock for product ${productId}. Available: ${inventory[0].stock}, Trying to return: ${deductibleQuantity}`);
            }

            const newStock = inventory[0].stock - deductibleQuantity;
            await connection.execute(
              `UPDATE inventory SET stock = ? WHERE product_id = ?`,
              [newStock, productId]
            );
        }

        // 4. Log Transaction
        const notes = `Return to Supplier - Reason: ${reason || 'N/A'} | Supplier ID: ${supplier} | Serials: ${serialsString} | Returned by: ${returnedBy}`;
        const transactionId = `TRX-${Date.now()}-${Math.floor(Math.random() * 10000)}`;
        
        await connection.execute(
          `INSERT INTO inventory_transactions (
             transaction_id, inventory_id, product_id, transaction_type,
             quantity, serial_number, notes, transaction_date, created_by
           ) VALUES (?, ?, ?, 'return_to_supplier', ?, ?, ?, ?, ?)`,
          [
            transactionId, inventoryId, productId,
            quantity, 
            serialsString !== 'N/A' ? serialsString : null,
            notes, transactionDate, returnedBy
          ]
        );
      }

      await connection.commit();
      return true;
    } catch (error) {
      await connection.rollback();
      throw error;
    } finally {
      connection.release();
    }
  }
}