import express from 'express';
import { ReturnController, uploadReturnPhoto } from '../../controllers/ReturnController.js';

const router = express.Router();

// Process a return (with photo upload)
router.post('/process', uploadReturnPhoto, ReturnController.processReturn);

// Get returns for a specific order
router.get('/order/:orderId', ReturnController.getReturnsByOrder);

// Get all returns with filters
router.get('/', ReturnController.getAllReturns);

// Get return statistics
router.get('/stats', ReturnController.getReturnStats);

export default router;
