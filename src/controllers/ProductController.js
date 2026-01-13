import { Product } from '../models/Product.js';
import { ActivityLog } from '../models/ActivityLog.js';

export class ProductController {
  
  static async getAllProducts(req, res) {
    try {
      const { search, category, brand, status, unit } = req.query;
      const page = parseInt(req.query.page) || 1;
      const limit = parseInt(req.query.limit) || 10;
      const offset = (page - 1) * limit;
      const filters = { search, category, brand, status, unit };
      const result = await Product.findAll(filters, limit, offset);
      const products = result.products || result || [];
      const totalCount = result.total || products.length;
      res.json({
        success: true,
        data: {
          products: products,
          pagination: {
            currentPage: page,
            totalPages: Math.ceil(totalCount / limit),
            totalProducts: totalCount,
            hasNextPage: (page * limit) < totalCount,
            hasPrevPage: page > 1
          }
        }
      });
    } catch (error) {
      console.error('Error fetching products:', error);
      res.status(500).json({ success: false, message: 'Failed to fetch products', error: error.message });
    }
  }

  static async getProductById(req, res) {
    try {
      const { id } = req.params;
      const product = await Product.findById(id);
      if (!product) return res.status(404).json({ success: false, message: 'Product not found' });
      res.json({ success: true, data: product });
    } catch (error) {
      console.error('Error fetching product:', error);
      res.status(500).json({ success: false, message: 'Failed to fetch product', error: error.message });
    }
  }

  // Create new product
  static async createProduct(req, res) {
    try {
      const productData = req.body;
      productData.image = req.file ? `/uploads/${req.file.filename}` : null;
      const rs = String(req.body.requires_serial);
      productData.requires_serial = rs === 'true' || rs === '1';

      const productId = await Product.create(productData);

      // [LOGGING]
      await ActivityLog.create({
        userId: req.body.userId || null,
        username: req.body.username || 'System',
        action: 'Create Product',
        details: `Created new product: "${productData.name}"`,
        ipAddress: req.ip
      });

      res.status(201).json({ success: true, message: 'Product created successfully', data: { id: productId } });
    } catch (error) {
      console.error('Error creating product:', error);
      res.status(500).json({ success: false, message: 'Failed to create product', error: error.message });
    }
  }

  // Update product
  static async updateProduct(req, res) {
    try {
      const { id } = req.params;
      const productData = req.body;
      const rs = String(req.body.requires_serial);
      productData.requires_serial = rs === 'true' || rs === '1';

      // 1. Validation & Name Fetching for Log
      const currentProduct = await Product.findById(id);
      const productName = currentProduct ? currentProduct.name : 'Unknown Product';

      if (productData.requires_serial === false && currentProduct && currentProduct.requires_serial) {
        const serialsExist = await Product.hasSerialNumbers(id); 
        if (serialsExist) throw new Error(`Cannot disable serial numbers. This product has existing serial numbers associated with it.`);
      }

      if (req.file) {
        productData.image = `/uploads/${req.file.filename}`;
      } else {
        if (productData.image === 'null') productData.image = null;
      }
      
      const updated = await Product.update(id, productData);
      if (!updated) return res.status(404).json({ success: false, message: 'Product not found' });

      // [LOGGING]
      await ActivityLog.create({
        userId: req.body.userId || null,
        username: req.body.username || 'System',
        action: 'Update Product',
        details: `Updated details for product: "${productName}"`,
        ipAddress: req.ip
      });

      res.json({ success: true, message: 'Product updated successfully' });
    } catch (error) {
      console.error('Error updating product:', error);
      res.status(500).json({ success: false, message: error.message || 'Failed to update product', error: error.message });
    }
  }

  // Delete product
  static async deleteProduct(req, res) {
    try {
      const { id } = req.params;
      
      // 1. Fetch name for Log before deletion
      const product = await Product.findById(id); 
      
      const deleted = await Product.delete(id);
      if (!deleted) return res.status(404).json({ success: false, message: 'Product not found' });

      // [LOGGING]
      await ActivityLog.create({
        userId: req.body.userId || req.query.userId || null, 
        username: req.body.username || req.query.username || 'System',
        action: 'Delete Product',
        details: `Deleted product: "${product ? product.name : id}"`,
        ipAddress: req.ip
      });

      res.json({ success: true, message: 'Product deleted successfully' });
    } catch (error) {
      console.error('Error deleting product:', error);
      if (error.code === 'PRODUCT_IN_USE') {
        return res.status(400).json({ success: false, message: 'Cannot delete product. This product is referenced in existing sales records.', error: error.message });
      }
      res.status(500).json({ success: false, message: 'Failed to delete product', error: error.message });
    }
  }

  static async getCategories(req, res) {
    try {
      const categories = await Product.getCategories();
      res.json({ success: true, data: categories });
    } catch (error) {
      console.error('Error fetching categories:', error);
      res.status(500).json({ success: false, message: 'Failed to fetch categories', error: error.message });
    }
  }

  static async getBrands(req, res) {
    try {
      const brands = await Product.getBrands();
      res.json({ success: true, data: brands });
    } catch (error) {
      console.error('Error fetching brands:', error);
      res.status(500).json({ success: false, message: 'Failed to fetch brands', error: error.message });
    }
  }
}