import express from 'express';
import { AuthController } from '../../controllers/AuthController.js';

const router = express.Router();

router.post('/login', AuthController.login);
router.post('/change-password', AuthController.changePassword);
router.post('/logout', (req, res) => {
  res.json({ success: true });
});

export default router;
