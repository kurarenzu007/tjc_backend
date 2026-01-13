import express from 'express';
import multer from 'multer';
import { ProductController } from '../../controllers/ProductController.js';


const router = express.Router();

// Multer configuration for file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'src/uploads/');
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, file.fieldname + '-' + uniqueSuffix + '.' + file.originalname.split('.').pop());
  }
});

const upload = multer({ storage: storage });

// GET /api/products - Get all products with optional filtering and pagination
router.get('/', ProductController.getAllProducts);

// GET /api/products/categories - Get all categories
router.get('/categories', ProductController.getCategories);

// GET /api/products/brands - Get all brands
router.get('/brands', ProductController.getBrands);

// GET /api/products/:id - Get product by ID
router.get('/:id', ProductController.getProductById);

// POST /api/products - Create new product
router.post('/', upload.single('image'), ProductController.createProduct);

// PUT /api/products/:id - Update product
router.put('/:id', upload.single('image'), ProductController.updateProduct);

// DELETE /api/products/:id - Delete product
router.delete('/:id', ProductController.deleteProduct);

export default router;
