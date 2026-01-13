import express from 'express';
import { InventoryController } from '../../controllers/InventoryController.js';

const router = express.Router();

// GET /api/inventory/stats - Get inventory statistics
router.get('/stats', InventoryController.getInventoryStats);

// GET /api/inventory/products - Get products with inventory information
router.get('/products', InventoryController.getProductsWithInventory);

// POST /api/inventory/bulk-stock-in - Bulk stock in for multiple products
router.post('/bulk-stock-in', InventoryController.bulkStockIn);

// POST /api/inventory/return-to-supplier - Return products to supplier
router.post('/return-to-supplier', InventoryController.returnToSupplier);

// PUT /api/inventory/:id/stock - Update product stock
router.put('/:id/stock', InventoryController.updateStock);

export default router;