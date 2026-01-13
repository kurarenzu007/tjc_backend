import { Return } from '../models/Return.js';
import multer from 'multer';
import path from 'path';
import fs from 'fs';

// Configure multer for photo uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const uploadDir = 'src/uploads/returns';
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    const uniqueName = `return-${Date.now()}-${Math.floor(Math.random() * 10000)}${path.extname(file.originalname)}`;
    cb(null, uniqueName);
  }
});

const upload = multer({
  storage,
  // [UPDATED] Increased limit to 50MB to handle high-res raw images
  limits: { fileSize: 50 * 1024 * 1024 }, 
  fileFilter: (req, file, cb) => {
    const allowedTypes = /jpeg|jpg|png|gif/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype);
    if (extname && mimetype) {
      cb(null, true);
    } else {
      cb(new Error('Only image files are allowed'));
    }
  }
});

// Wrapped middleware to handle "File Too Large" errors gracefully
export const uploadReturnPhoto = (req, res, next) => {
  upload.single('photoProof')(req, res, (err) => {
    if (err instanceof multer.MulterError) {
      if (err.code === 'LIMIT_FILE_SIZE') {
        return res.status(400).json({ 
          success: false, 
          // [UPDATED] Error message reflects new limit
          message: 'File is too large. Please upload an image smaller than 50MB.' 
        });
      }
      return res.status(400).json({ success: false, message: err.message });
    } else if (err) {
      return res.status(400).json({ success: false, message: err.message });
    }
    next();
  });
};

export const ReturnController = {
  // Process a return
  processReturn: async (req, res) => {
    try {
      const {
        orderId,
        saleNumber,
        customerName,
        returnReason,
        refundMethod,
        restocked,
        additionalNotes,
        returnItems: returnItemsString
      } = req.body;
      
      // Parse returnItems from JSON string (FormData sends it as string)
      const returnItems = JSON.parse(returnItemsString || '[]');
      
      // Get photo proof path if uploaded
      const photoProof = req.file ? `/uploads/returns/${req.file.filename}` : null;

      // Validation
      if (!orderId || !returnReason || !refundMethod || !returnItems || returnItems.length === 0) {
        return res.status(400).json({
          success: false,
          message: 'Missing required fields'
        });
      }

      // Validate at least one item has quantity > 0
      const hasValidItems = returnItems.some(item => item.quantity > 0);
      if (!hasValidItems) {
        return res.status(400).json({
          success: false,
          message: 'At least one item must have quantity greater than 0'
        });
      }

      // Get processed by from session/auth
      const processedBy = req.body.processedBy || req.user?.username || 'Admin';

      const result = await Return.processReturn({
        orderId,
        saleNumber,
        customerName,
        returnReason,
        refundMethod,
        restocked: restocked !== false, // Default to true
        photoProof,
        additionalNotes,
        processedBy,
        returnItems
      });

      res.json({
        success: true,
        message: 'Return processed successfully',
        data: result
      });
    } catch (error) {
      console.error('Process return error:', error);
      res.status(500).json({
        success: false,
        message: error.message || 'Failed to process return'
      });
    }
  },

  // Get return history for an order
  getReturnsByOrder: async (req, res) => {
    try {
      const { orderId } = req.params;

      const returns = await Return.getReturnsByOrderId(orderId);

      res.json({
        success: true,
        data: returns
      });
    } catch (error) {
      console.error('Get returns error:', error);
      res.status(500).json({
        success: false,
        message: error.message || 'Failed to fetch returns'
      });
    }
  },

  // Get all returns with filters
  getAllReturns: async (req, res) => {
    try {
      const { startDate, endDate, returnReason, limit, offset } = req.query;

      const filters = {
        startDate,
        endDate,
        returnReason,
        limit: limit || 50,
        offset: offset || 0
      };

      const returns = await Return.getAllReturns(filters);

      res.json({
        success: true,
        data: returns
      });
    } catch (error) {
      console.error('Get all returns error:', error);
      res.status(500).json({
        success: false,
        message: error.message || 'Failed to fetch returns'
      });
    }
  },

  // Get return statistics
  getReturnStats: async (req, res) => {
    try {
      const stats = await Return.getReturnStats();

      res.json({
        success: true,
        data: stats
      });
    } catch (error) {
      console.error('Get return stats error:', error);
      res.status(500).json({
        success: false,
        message: error.message || 'Failed to fetch return statistics'
      });
    }
  }
};