import express from 'express';
import { SettingsController } from '../../controllers/SettingsController.js';

const router = express.Router();

router.get('/', SettingsController.getSettings);
router.put('/', SettingsController.updateBusinessInfo);
router.put('/preferences', SettingsController.updatePreferences);

export default router;
