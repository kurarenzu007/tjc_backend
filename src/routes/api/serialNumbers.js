import express from 'express';
import { SerialNumberController } from '../../controllers/SerialNumberController.js';

const router = express.Router();

// GET /api/serial-numbers/product/:productId/available - Get available serial numbers for a product
router.get('/product/:productId/available', SerialNumberController.getAvailableSerials);

// [NEW] GET /api/serial-numbers/product/:productId/returnable - Get returnable serials (Available + Defective)
router.get('/product/:productId/returnable', SerialNumberController.getReturnableSerials);

// GET /api/serial-numbers/product/:productId - Get all serial numbers for a product
router.get('/product/:productId', SerialNumberController.getAllSerials);

// GET /api/serial-numbers/sale/:saleId - Get serial numbers by sale ID
router.get('/sale/:saleId', SerialNumberController.getBySaleId);

// POST /api/serial-numbers - Create serial numbers
router.post('/', SerialNumberController.createSerials);

// PUT /api/serial-numbers/mark-sold - Mark serial numbers as sold
router.put('/mark-sold', SerialNumberController.markAsSold);

// PUT /api/serial-numbers/defective - Mark serial numbers as defective
router.put('/defective', SerialNumberController.markAsDefective);

// DELETE /api/serial-numbers - Delete serial numbers
router.delete('/', SerialNumberController.deleteSerials);

export default router;