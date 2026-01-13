import express from 'express';
import multer from 'multer';
import { SalesController } from '../../controllers/SalesController.js';

const router = express.Router();

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'src/uploads/');
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
    cb(null, 'delivery-' + uniqueSuffix + '.' + file.originalname.split('.').pop());
  }
});
const upload = multer({ storage });

// Create a new sale
router.post('/', SalesController.createSale);

// Get all sales with optional filters and pagination
router.get('/', SalesController.getAllSales);

// Get sales statistics
router.get('/stats', SalesController.getSalesStats);

// Get a specific sale with its items
router.get('/:id', SalesController.getSaleById);

// Get items for a specific sale
router.get('/:sale_id/items', SalesController.getSaleItems);

// Update a sale
router.put('/:id', SalesController.updateSale);

// Upload delivery proof for a sale
router.post('/:id/delivery-proof', upload.single('proof'), SalesController.uploadDeliveryProof);

// Delete a sale (restores inventory)
router.delete('/:id', SalesController.deleteSale);

export default router;
