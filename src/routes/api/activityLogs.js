import express from 'express';
import { ActivityLogController } from '../../controllers/ActivityLogController.js';

const router = express.Router();

router.get('/', ActivityLogController.getLogs);
router.get('/stats', ActivityLogController.getStats); // [NEW]
router.post('/prune', ActivityLogController.pruneLogs); // [NEW]

export default router;