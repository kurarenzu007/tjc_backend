import express from 'express';
import { ReportsController } from '../../controllers/ReportsController.js';

const router = express.Router();

// Get sales report data with pagination and filtering
router.get('/sales', ReportsController.getSalesReport);

// Get inventory report data with pagination and filtering
router.get('/inventory', ReportsController.getInventoryReport);

// [NEW] Get Dead Stock Report
router.get('/dead-stock', ReportsController.getDeadStockReport);

// Get returns report
router.get('/returns', ReportsController.getReturnsReport);

// Get filter options (brands and categories)
router.get('/filter-options', ReportsController.getFilterOptions);

export default router;