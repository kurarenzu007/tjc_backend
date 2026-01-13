import { Sales } from '../models/Sales.js';
import { Return } from '../models/Return.js';
import { getPool } from '../config/database.js';

export class ReportsController {
  // Helper: Convert UTC to Philippine Time
  static convertToPhilippineTime(utcDateString) {
    if (!utcDateString) return null;
    try {
      const utcDate = new Date(utcDateString);
      utcDate.setHours(utcDate.getHours() + 8);
      return utcDate.toISOString().replace('Z', '+08:00');
    } catch (e) {
      return utcDateString; // Fallback if date parsing fails
    }
  }

  // 1. SALES REPORT
  static async getSalesReport(req, res) {
    try {
      const { page = 1, limit = 10, start_date, end_date } = req.query;
      const offset = (parseInt(page) - 1) * parseInt(limit);
      const pool = getPool();

      const baseWhere = `
        WHERE s.status NOT IN ('Cancelled', 'Returned')
        AND (s.payment_status != 'Refunded' OR s.payment_status IS NULL)
        AND (si.quantity - COALESCE(si.returned_quantity, 0)) > 0
      `;

      let dateFilter = '';
      let params = [];

      if (start_date) {
        dateFilter += ' AND DATE(DATE_ADD(s.created_at, INTERVAL 8 HOUR)) >= ?';
        params.push(start_date);
      }
      if (end_date) {
        dateFilter += ' AND DATE(DATE_ADD(s.created_at, INTERVAL 8 HOUR)) <= ?';
        params.push(end_date);
      }

      const query = `
        SELECT 
          si.product_name,
          si.brand,
          si.price as unit_price,
          (si.quantity - COALESCE(si.returned_quantity, 0)) as quantity_sold,
          ((si.quantity - COALESCE(si.returned_quantity, 0)) * si.price) as total_item_price,
          s.id as sale_id,
          s.sale_number as order_id,
          s.customer_name,
          s.created_at as order_date,
          s.payment as payment_method,
          s.payment_status as payment_status
        FROM sale_items si
        JOIN sales s ON si.sale_id = s.id
        ${baseWhere}
        ${dateFilter}
        ORDER BY s.created_at DESC
        LIMIT ? OFFSET ?
      `;
      
      const queryParams = [...params, parseInt(limit), parseInt(offset)];
      const [items] = await pool.execute(query, queryParams);

      // Get Counts and Summary
      const summaryQuery = `
        SELECT 
          COUNT(DISTINCT s.id) as total_sales_count,
          COUNT(*) as total_items_count,
          SUM((si.quantity - COALESCE(si.returned_quantity, 0)) * si.price) as total_revenue
        FROM sale_items si
        JOIN sales s ON si.sale_id = s.id
        ${baseWhere}
        ${dateFilter}
      `;
      const [summaryResult] = await pool.execute(summaryQuery, params);
      const stats = summaryResult[0] || {};
      
      const summary = {
        totalSales: stats.total_sales_count || 0,
        totalRevenue: stats.total_revenue || 0,
        averageSale: 0,
        totalItems: stats.total_items_count || 0
      };

      if (summary.totalSales > 0) {
        summary.averageSale = summary.totalRevenue / summary.totalSales;
      }

      const formattedItems = Array.isArray(items) ? items.map(item => ({
        id: `${item.sale_id}-${item.product_name}`,
        orderId: item.order_id,
        customerName: item.customer_name,
        productName: item.product_name,
        brand: item.brand,
        quantity: item.quantity_sold,
        unitPrice: parseFloat(item.unit_price),
        totalPrice: parseFloat(item.total_item_price),
        orderDate: ReportsController.convertToPhilippineTime(item.order_date),
        paymentMethod: item.payment_method || 'N/A',
        paymentStatus: item.payment_status || 'Unpaid'
      })) : [];

      res.json({
        success: true,
        data: {
          sales: formattedItems,
          pagination: {
            current_page: parseInt(page),
            per_page: parseInt(limit),
            total: summary.totalItems,
            total_pages: Math.ceil(summary.totalItems / parseInt(limit)) || 1,
          },
          summary: summary
        }
      });

    } catch (error) {
      console.error('Error fetching sales report:', error);
      res.status(500).json({ success: false, message: 'Failed to fetch sales report' });
    }
  }

  // 2. INVENTORY REPORT
  static async getInventoryReport(req, res) {
    try {
      const { page = 1, limit = 10, search, category, brand, status, stock_status, type } = req.query; // [FIX] Added 'type'
      const offset = (parseInt(page) - 1) * parseInt(limit);
      const pool = getPool();

      // --- 1. BUILD BASE FILTERS ---
      let baseConditions = `WHERE 1=1`;
      let params = [];

      if (search) {
        baseConditions += ' AND (p.name LIKE ? OR p.product_id LIKE ? OR p.brand LIKE ?)';
        params.push(`%${search}%`, `%${search}%`, `%${search}%`);
      }
      if (category && category !== 'All Categories') {
        baseConditions += ' AND p.category = ?';
        params.push(category);
      }
      if (brand && brand !== 'All Brand') {
        baseConditions += ' AND p.brand = ?';
        params.push(brand);
      }
      if (status && status !== 'All Status') {
        baseConditions += ' AND p.status = ?';
        params.push(status);
      }
      
      // [FIX] Filter by Product Type
      if (type) {
        if (type === 'Serialized') {
            baseConditions += ' AND p.requires_serial = 1';
        } else if (type === 'Standard') {
            baseConditions += ' AND p.requires_serial = 0';
        }
      }

      // --- 2. HANDLE STOCK STATUS LOGIC ---
      if (stock_status && stock_status !== 'All Status') {
        if (stock_status === 'Out of Stock') {
          baseConditions += ' AND (COALESCE(i.stock, 0) <= 0 OR i.stock IS NULL)'; 
        } else if (stock_status === 'Low Stock') {
          baseConditions += ' AND COALESCE(i.stock, 0) <= COALESCE(i.reorder_point, 10) AND COALESCE(i.stock, 0) > 0';
        } else if (stock_status === 'In Stock') {
          baseConditions += ' AND COALESCE(i.stock, 0) > COALESCE(i.reorder_point, 10)'; 
        }
      }

      // --- 3. SUMMARY STATS QUERY (Real-time) ---
      const summaryQuery = `
        SELECT 
          COUNT(*) as totalProducts,
          SUM(COALESCE(p.price, 0) * GREATEST(COALESCE(i.stock, 0), 0)) as totalInventoryValue,
          SUM(CASE WHEN COALESCE(i.stock, 0) <= 0 OR i.stock IS NULL THEN 1 ELSE 0 END) as outOfStockProducts,
          SUM(CASE WHEN COALESCE(i.stock, 0) <= COALESCE(i.reorder_point, 10) AND COALESCE(i.stock, 0) > 0 THEN 1 ELSE 0 END) as lowStockProducts
        FROM products p
        LEFT JOIN inventory i ON p.product_id = i.product_id
        ${baseConditions}
      `;
      
      const [summaryResult] = await pool.execute(summaryQuery, params);
      const stats = summaryResult[0] || {};

      const summary = {
        totalProducts: stats.totalProducts || 0,
        inStockProducts: (stats.totalProducts || 0) - ((stats.outOfStockProducts || 0) + (stats.lowStockProducts || 0)), 
        lowStockProducts: stats.lowStockProducts || 0,
        outOfStockProducts: stats.outOfStockProducts || 0,
        totalInventoryValue: stats.totalInventoryValue || 0
      };

      // --- 4. DATA LIST QUERY ---
      const listQuery = `
        SELECT p.product_id, p.name, p.brand, p.category, p.price, p.status, p.requires_serial,
               p.created_at,
               COALESCE(i.stock, 0) as current_stock,
               COALESCE(i.reorder_point, 10) as reorder_point,
               CASE
                 WHEN COALESCE(i.stock, 0) <= 0 OR i.stock IS NULL THEN 'Out of Stock'
                 WHEN COALESCE(i.stock, 0) < COALESCE(i.reorder_point, 10) THEN 'Low Stock'
                 ELSE 'In Stock'
               END as stock_status
        FROM products p
        LEFT JOIN inventory i ON p.product_id = i.product_id
        ${baseConditions}
        ORDER BY p.created_at DESC 
        LIMIT ? OFFSET ?
      `;

      const listParams = [...params, parseInt(limit), parseInt(offset)];
      const [products] = await pool.execute(listQuery, listParams);

      res.json({
        success: true,
        data: {
          products: Array.isArray(products) ? products.map(product => ({
            id: product.product_id,
            productName: product.name || 'N/A',
            category: product.category || 'N/A',
            brand: product.brand || 'N/A',
            currentStock: product.current_stock || 0,
            stockStatus: product.stock_status || 'Out of Stock',
            price: parseFloat(product.price || 0),
            status: product.status || 'N/A',
            requires_serial: !!product.requires_serial,
            createdDate: ReportsController.convertToPhilippineTime(product.created_at)
          })) : [],
          pagination: {
            current_page: parseInt(page),
            per_page: parseInt(limit),
            total: summary.totalProducts, 
            total_pages: Math.ceil(summary.totalProducts / parseInt(limit)) || 1,
          },
          summary: summary
        }
      });
    } catch (error) {
      console.error('Error fetching inventory report:', error);
      res.status(500).json({ success: false, message: 'Failed to fetch inventory report' });
    }
  }

  // 3. SMART DEAD STOCK REPORT
  static async getDeadStockReport(req, res) {
    try {
      const { page = 1, limit = 10, months = 6, brand, category } = req.query;
      const offset = (parseInt(page) - 1) * parseInt(limit);
      const pool = getPool();
      
      const filterParams = [];
      let filters = "";
      if (brand && brand !== 'All Brand') { filters += ` AND p.brand = ?`; filterParams.push(brand); }
      if (category && category !== 'All Categories') { filters += ` AND p.category = ?`; filterParams.push(category); }

      const monthsInt = parseInt(months) || 6;

      // Check Creation Date if Never Sold to protect new products
      const havingClause = `
        (last_activity_date < DATE_SUB(NOW(), INTERVAL ? MONTH) 
        OR (last_activity_date IS NULL AND p.created_at < DATE_SUB(NOW(), INTERVAL ? MONTH)))
      `;

      // 1. Fetch Dead SKUs (Whole product line is dormant)
      const skuQuery = `
        SELECT 
          'SKU' as type,
          p.product_id, p.name, p.brand, p.category, p.price, p.created_at,
          COALESCE(i.stock, 0) as current_stock,
          MAX(s.created_at) as last_activity_date,
          DATEDIFF(NOW(), MAX(s.created_at)) as days_dormant,
          NULL as serial_number
        FROM products p
        JOIN inventory i ON p.product_id = i.product_id
        LEFT JOIN sale_items si ON p.product_id = si.product_id
        LEFT JOIN sales s ON si.sale_id = s.id AND s.status NOT IN ('Cancelled', 'Returned')
        WHERE i.stock > 0
        ${filters}
        GROUP BY p.product_id
        HAVING ${havingClause}
      `;
      const [deadSKUs] = await pool.execute(skuQuery, [...filterParams, monthsInt, monthsInt]);

      // 2. Fetch Aged Serials (Specific units old, but product might be active)
      const deadSkuIds = Array.isArray(deadSKUs) ? deadSKUs.map(i => i.product_id) : [];
      let excludeClause = "";
      if (deadSkuIds.length > 0) {
          const placeholders = deadSkuIds.map(() => '?').join(',');
          excludeClause = `AND p.product_id NOT IN (${placeholders})`;
      }

      const serialQuery = `
        SELECT 
          'Serial' as type,
          p.product_id, p.name, p.brand, p.category, p.price,
          1 as current_stock,
          sn.created_at as last_activity_date,
          DATEDIFF(NOW(), sn.created_at) as days_dormant,
          sn.serial_number
        FROM serial_numbers sn
        JOIN products p ON sn.product_id = p.product_id
        WHERE sn.status = 'available'
        AND sn.created_at < DATE_SUB(NOW(), INTERVAL ? MONTH)
        ${filters}
        ${excludeClause}
      `;
      
      const serialParams = [monthsInt, ...filterParams, ...deadSkuIds];
      const [agedSerials] = await pool.execute(serialQuery, serialParams);

      // 3. Merge, Sort, and Paginate
      const allDeadStock = [...(deadSKUs || []), ...(agedSerials || [])];
      allDeadStock.sort((a, b) => (b.price * b.current_stock) - (a.price * a.current_stock));

      const totalItems = allDeadStock.length;
      const paginatedData = allDeadStock.slice(offset, offset + parseInt(limit));

      const summary = {
        totalDeadItems: totalItems,
        totalDeadValue: allDeadStock.reduce((acc, item) => acc + (item.price * item.current_stock), 0)
      };

      res.json({
        success: true,
        data: {
          deadStock: paginatedData.map(item => ({
            id: item.serial_number ? `${item.product_id}-${item.serial_number}` : item.product_id,
            type: item.type,
            name: item.name,
            brand: item.brand,
            category: item.category,
            price: parseFloat(item.price),
            currentStock: item.current_stock,
            serialNumber: item.serial_number || null,
            lastActivity: item.last_activity_date ? ReportsController.convertToPhilippineTime(item.last_activity_date) : null,
            daysDormant: item.days_dormant !== null 
                ? `${item.days_dormant} days` 
                : `${Math.floor((new Date() - new Date(item.created_at)) / (1000 * 60 * 60 * 24))} days (Never Sold)`,
            tiedUpValue: parseFloat(item.price) * item.current_stock,
            reason: item.type === 'SKU' ? 'Product not selling' : 'Old Unit / Aged Stock'
          })),
          pagination: {
            current_page: parseInt(page),
            per_page: parseInt(limit),
            total: totalItems,
            total_pages: Math.ceil(totalItems / parseInt(limit)) || 1
          },
          summary
        }
      });

    } catch (error) {
      console.error('Error fetching dead stock report:', error);
      res.status(500).json({ success: false, message: 'Failed to fetch dead stock report' });
    }
  }

  // 4. RETURNS REPORT
  static async getReturnsReport(req, res) {
    try {
      const { page = 1, limit = 10, start_date, end_date, returnReason } = req.query;
      const offset = (parseInt(page) - 1) * parseInt(limit);

      const filters = { startDate: start_date, endDate: end_date, returnReason, limit: parseInt(limit), offset: parseInt(offset) };
      const returns = await Return.getAllReturns(filters);

      // Eager Load Return Items
      const pool = getPool();
      if (returns && returns.length > 0) {
          const returnIds = returns.map(r => r.return_id);
          const placeholders = returnIds.map(() => '?').join(',');
          
          const [items] = await pool.execute(
              `SELECT * FROM return_items WHERE return_id IN (${placeholders})`,
              returnIds
          );

          const itemsMap = {};
          (items || []).forEach(i => {
              if(!itemsMap[i.return_id]) itemsMap[i.return_id] = [];
              itemsMap[i.return_id].push(i);
          });

          returns.forEach(r => {
              r.items = itemsMap[r.return_id] || [];
          });
      }

      let countQuery = "SELECT COUNT(*) as total FROM returns WHERE 1=1";
      let countParams = [];
      if (start_date) { countQuery += ' AND return_date >= ?'; countParams.push(start_date); }
      if (end_date) { countQuery += ' AND return_date <= ?'; countParams.push(end_date); }
      if (returnReason) { countQuery += ' AND return_reason = ?'; countParams.push(returnReason); }

      const [totalResult] = await pool.execute(countQuery, countParams);
      const total = totalResult[0].total;

      const summary = await Return.getReturnStats();

      res.json({
        success: true,
        data: {
          returns: returns || [],
          pagination: {
            current_page: parseInt(page),
            per_page: parseInt(limit),
            total: total,
            total_pages: Math.ceil(total / parseInt(limit)) || 1,
          },
          summary: summary
        }
      });
    } catch (error) {
      console.error('Error fetching returns report:', error);
      res.status(500).json({ success: false, message: 'Failed to fetch returns report' });
    }
  }

  // 5. FILTER OPTIONS
  static async getFilterOptions(req, res) {
    try {
      const pool = getPool();
      const [brands] = await pool.execute(`SELECT DISTINCT brand FROM products WHERE brand IS NOT NULL AND brand != '' AND status = 'Active' ORDER BY brand`);
      const [categories] = await pool.execute(`SELECT DISTINCT category FROM products WHERE category IS NOT NULL AND category != '' AND status = 'Active' ORDER BY category`);

      res.json({
        success: true,
        data: {
          brands: (brands || []).map(b => b.brand),
          categories: (categories || []).map(c => c.category)
        }
      });
    } catch (error) {
      console.error('Error fetching filter options:', error);
      res.status(500).json({ success: false, message: 'Failed to fetch filter options' });
    }
  }
}