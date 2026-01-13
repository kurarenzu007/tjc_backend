import express from 'express';
import multer from 'multer';
import { UsersController } from '../../controllers/UsersController.js';

const router = express.Router();

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'src/uploads/');
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
    cb(null, 'avatar-' + uniqueSuffix + '.' + file.originalname.split('.').pop());
  }
});
const upload = multer({ storage });

router.get('/', UsersController.list);
router.get('/:id', UsersController.getById); // [NEW] Fetch single user
router.post('/', upload.single('avatar'), UsersController.create);
router.put('/:id', upload.single('avatar'), UsersController.update);

export default router;