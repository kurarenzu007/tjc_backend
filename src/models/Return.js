import { getPool } from '../config/database.js';

export class Return {
  // Process a return for an order
  static async processReturn(returnData) {
    const pool = getPool();
    const connection = await pool.getConnection();

    try {
      await connection.beginTransaction();

      const {
        orderId,
        saleNumber,
        customerName,
        returnReason,
        refundMethod,
        referenceNumber,
        restocked,
        photoProof,
        additionalNotes,
        processedBy,
        returnItems 
      } = returnData;

      // Validate that order exists and can be returned
      const [orderResult] = await connection.execute(
        'SELECT * FROM sales WHERE id = ?',
        [orderId]
      );

      if (!orderResult[0]) {
        throw new Error('Order not found');
      }

      const order = orderResult[0];

      if (order.status === 'Returned') {
        throw new Error('Order has already been fully returned');
      }

      if (order.status === 'Cancelled') {
        throw new Error('Cannot return a cancelled order');
      }

      // [FIXED] Standardized Return ID: RET-YYMMDD-XXXX (15 Chars)
      const dateStr = new Date().toISOString().slice(2, 10).replace(/-/g, ''); // YYMMDD
      const randomSuffix = Math.floor(1000 + Math.random() * 9000); // 4-digit random number
      const returnId = `RET-${dateStr}-${randomSuffix}`;

      // Calculate total refund amount
      const refundAmount = returnItems.reduce((total, item) => {
        return total + (parseFloat(item.price) * parseInt(item.quantity));
      }, 0);

      // Get all sale items for this order to check if it's a full or partial return
      const [allSaleItems] = await connection.execute(
        'SELECT id, quantity, COALESCE(returned_quantity, 0) as returned_quantity FROM sale_items WHERE sale_id = ?',
        [orderId]
      );

      // Validate return quantities
      for (const returnItem of returnItems) {
        const saleItem = allSaleItems.find(si => si.id === returnItem.saleItemId);
        if (!saleItem) {
          throw new Error(`Sale item ${returnItem.saleItemId} not found`);
        }

        const remainingQuantity = saleItem.quantity - saleItem.returned_quantity;
        if (returnItem.quantity > remainingQuantity) {
          throw new Error(`Cannot return more than ${remainingQuantity} units of ${returnItem.productName}`);
        }
      }

      // Insert return record
      await connection.execute(
        `INSERT INTO returns (
          return_id, order_id, sale_number, customer_name, return_date,
          return_reason, refund_method, reference_number, refund_amount, restocked,
          photo_proof, additional_notes, processed_by
        ) VALUES (?, ?, ?, ?, NOW(), ?, ?, ?, ?, ?, ?, ?, ?)`,
        [
          returnId,
          orderId,
          saleNumber,
          customerName,
          returnReason,
          refundMethod,
          referenceNumber || null,
          refundAmount,
          restocked,
          photoProof || null,
          additionalNotes || null,
          processedBy
        ]
      );

      // Insert return items and update sale_items
      for (const returnItem of returnItems) {
        const serialsToStore = (returnItem.serialNumbers && returnItem.serialNumbers.length > 0)
            ? returnItem.serialNumbers.join(', ')
            : null;

        await connection.execute(
          `INSERT INTO return_items (
            return_id, sale_item_id, product_id, product_name, sku,
            quantity, price, subtotal, serial_numbers
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
          [
            returnId,
            returnItem.saleItemId,
            returnItem.productId,
            returnItem.productName,
            returnItem.sku || null,
            returnItem.quantity,
            returnItem.price,
            returnItem.quantity * returnItem.price,
            serialsToStore
          ]
        );

        await connection.execute(
          'UPDATE sale_items SET returned_quantity = returned_quantity + ? WHERE id = ?',
          [returnItem.quantity, returnItem.saleItemId]
        );

        // Serial Number Handling
        if (returnItem.serialNumbers && returnItem.serialNumbers.length > 0) {
           let serialStatus = 'returned'; 
           if (restocked) {
             serialStatus = 'available';
           } else if (returnReason === 'Defective/Damaged') {
             serialStatus = 'defective';
           }

           for (const serial of returnItem.serialNumbers) {
             await connection.execute(
               `UPDATE serial_numbers 
                SET status = ?, sale_id = NULL, sale_item_id = NULL, updated_at = NOW(), notes = ?
                WHERE serial_number = ? AND product_id = ?`,
               [serialStatus, `Returned from order ${saleNumber}: ${returnReason}`, serial, returnItem.productId]
             );
           }
        }

        // If restocked, update inventory count
        if (restocked) {
          await connection.execute(
            'UPDATE inventory SET stock = stock + ? WHERE product_id = ?',
            [returnItem.quantity, returnItem.productId]
          );

          // Record inventory transaction
          const txnId = `TRX-${Date.now()}-${Math.floor(Math.random() * 1000)}`;
          const [inventoryResult] = await connection.execute(
            'SELECT id FROM inventory WHERE product_id = ?',
            [returnItem.productId]
          );

          if (inventoryResult[0]) {
            await connection.execute(
              `INSERT INTO inventory_transactions (
                transaction_id, inventory_id, product_id, transaction_type,
                quantity, notes, transaction_date, created_by
              ) VALUES (?, ?, ?, 'in', ?, ?, NOW(), ?)`,
              [
                txnId,
                inventoryResult[0].id,
                returnItem.productId,
                returnItem.quantity,
                `Return from order ${saleNumber} - ${returnReason}`,
                processedBy
              ]
            );
          }
        }
      }

      // Check if all items have been returned
      const [updatedSaleItems] = await connection.execute(
        'SELECT id, quantity, COALESCE(returned_quantity, 0) as returned_quantity FROM sale_items WHERE sale_id = ?',
        [orderId]
      );

      const allItemsReturned = updatedSaleItems.every(
        item => item.returned_quantity >= item.quantity
      );

      const hasPartialReturns = updatedSaleItems.some(
        item => item.returned_quantity > 0 && item.returned_quantity < item.quantity
      );

      let newStatus = order.status;
      let newPaymentStatus = order.payment_status;

      if (allItemsReturned) {
        newStatus = 'Returned';
        newPaymentStatus = 'Refunded';
      } else if (hasPartialReturns || updatedSaleItems.some(item => item.returned_quantity > 0)) {
        newStatus = 'Partially Returned';
        newPaymentStatus = 'Partially Refunded';
      }

      // Update order with return information
      const totalRefundAmount = parseFloat(order.refund_amount || 0) + refundAmount;
      await connection.execute(
        `UPDATE sales SET 
          status = ?,
          payment_status = ?,
          refund_amount = ?,
          return_date = NOW(),
          return_reason = ?
        WHERE id = ?`,
        [newStatus, newPaymentStatus, totalRefundAmount, returnReason, orderId]
      );

      // Create refund transaction record
      const refundTxnId = `RFND-${Date.now()}-${Math.floor(Math.random() * 10000)}`;
      await connection.execute(
        `INSERT INTO refund_transactions (
          transaction_id, return_id, order_id, amount, refund_method,
          transaction_date, notes, processed_by
        ) VALUES (?, ?, ?, ?, ?, NOW(), ?, ?)`,
        [
          refundTxnId,
          returnId,
          orderId,
          refundAmount,
          refundMethod,
          `Return processed: ${returnReason}${additionalNotes ? ' - ' + additionalNotes : ''}`,
          processedBy
        ]
      );

      await connection.commit();

      return {
        returnId,
        refundAmount,
        newStatus,
        newPaymentStatus,
        refundTxnId
      };
    } catch (error) {
      await connection.rollback();
      throw error;
    } finally {
      connection.release();
    }
  }

  // Get return history for an order
  static async getReturnsByOrderId(orderId) {
    const pool = getPool();
    const [returns] = await pool.execute(
      `SELECT * FROM returns WHERE order_id = ? ORDER BY return_date DESC`,
      [orderId]
    );

    for (const returnRecord of returns) {
      const [items] = await pool.execute(
        `SELECT * FROM return_items WHERE return_id = ?`,
        [returnRecord.return_id]
      );
      returnRecord.items = items;
    }

    return returns;
  }

  // Get all returns with pagination and filters
  static async getAllReturns(filters = {}) {
    const pool = getPool();
    // [FIX] Changed 's.payment_method' to 's.payment' to match database schema
    let query = `
      SELECT r.*, s.customer_name, s.payment as payment
      FROM returns r
      LEFT JOIN sales s ON r.order_id = s.id
      WHERE 1=1
    `;
    const params = [];

    if (filters.startDate) {
      query += ' AND r.return_date >= ?';
      params.push(filters.startDate);
    }

    if (filters.endDate) {
      query += ' AND r.return_date <= ?';
      params.push(filters.endDate);
    }

    if (filters.returnReason) {
      query += ' AND r.return_reason = ?';
      params.push(filters.returnReason);
    }

    query += ' ORDER BY r.return_date DESC';

    if (filters.limit) {
      query += ' LIMIT ? OFFSET ?';
      params.push(parseInt(filters.limit), parseInt(filters.offset || 0));
    }

    const [returns] = await pool.execute(query, params);
    
    // Fetch Items for returns if needed (optional optimization loop here)
    for (const ret of returns) {
         const [items] = await pool.execute('SELECT product_name, serial_numbers FROM return_items WHERE return_id = ?', [ret.return_id]);
         ret.items = items;
    }

    return returns;
  }

  // Get return statistics
  static async getReturnStats() {
    const pool = getPool();
    const [stats] = await pool.execute(`
      SELECT 
        COUNT(*) as totalReturns,
        SUM(refund_amount) as totalRefundAmount,
        COUNT(CASE WHEN restocked = 1 THEN 1 END) as restockedReturns,
        COUNT(CASE WHEN return_reason = 'Defective/Damaged' THEN 1 END) as defectiveReturns
      FROM returns
    `);

    return stats[0];
  }
}