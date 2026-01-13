import bcrypt from 'bcryptjs';
import { getPool } from '../config/database.js';

export class UsersController {
  // [NEW] Get single user by ID for Profile Page
  static async getById(req, res) {
    try {
      const { id } = req.params;
      const pool = getPool();
      const [rows] = await pool.execute(
        'SELECT id, username, first_name, middle_name, last_name, email, role, status, avatar FROM users WHERE id = ?',
        [id]
      );
      
      if (rows.length === 0) {
        return res.status(404).json({ success: false, message: 'User not found' });
      }

      res.json({ success: true, data: rows[0] });
    } catch (err) {
      console.error('Get user error:', err);
      res.status(500).json({ success: false, message: 'Failed to fetch user profile' });
    }
  }

  static async list(req, res) {
    try {
      const pool = getPool();
      const [rows] = await pool.execute('SELECT id, username, first_name, middle_name, last_name, email, role, status, avatar FROM users ORDER BY created_at DESC');
      res.json({ success: true, data: rows });
    } catch (err) {
      console.error('List users error:', err);
      res.status(500).json({ success: false, message: 'Failed to fetch users' });
    }
  }

  static async create(req, res) {
    try {
      const { username, first_name, middle_name, last_name, email, password, role = 'staff', status = 'Active' } = req.body;
      if (!email || !password) {
        return res.status(400).json({ success: false, message: 'email and password are required' });
      }
      
      const pool = getPool();
      const hash = await bcrypt.hash(password, 10);
      const avatarPath = req.file ? `/${req.file.path.replace(/\\/g, '/')}`.replace('src/', '') : null;
      
      // Auto-generate username if missing
      const fullUsername = username || `${last_name}, ${first_name}${middle_name ? ' ' + middle_name : ''}`;
      
      await pool.execute(
        'INSERT INTO users (username, first_name, middle_name, last_name, email, password_hash, role, status, avatar) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
        [fullUsername, first_name, middle_name || null, last_name, email, hash, role, status, avatarPath]
      );
      res.status(201).json({ success: true, message: 'User created' });
    } catch (err) {
      console.error('Create user error:', err);
      res.status(500).json({ success: false, message: 'Failed to create user' });
    }
  }

  static async update(req, res) {
    try {
      const { id } = req.params;
      // [UPDATED] Accept more fields for profile updates
      const { username, first_name, last_name, email, role, status } = req.body;
      const pool = getPool();
      const updates = [];
      const params = [];
      
      if (username !== undefined) { updates.push('username = ?'); params.push(username); }
      if (first_name !== undefined) { updates.push('first_name = ?'); params.push(first_name); }
      if (last_name !== undefined) { updates.push('last_name = ?'); params.push(last_name); }
      if (email !== undefined) { updates.push('email = ?'); params.push(email); }
      if (role !== undefined) { updates.push('role = ?'); params.push(role); }
      if (status !== undefined) { updates.push('status = ?'); params.push(status); }
      
      let avatarPath = null;
      if (req.file) { 
        avatarPath = `/${req.file.path.replace(/\\/g, '/')}`.replace('src/', '');
        updates.push('avatar = ?'); 
        params.push(avatarPath); 
      }

      if (updates.length === 0) return res.status(400).json({ success: false, message: 'No fields to update' });
      
      params.push(id);
      await pool.execute(`UPDATE users SET ${updates.join(', ')} WHERE id = ?`, params);
      
      res.json({ success: true, message: 'Profile updated successfully', avatar: avatarPath || undefined });
    } catch (err) {
      console.error('Update user error:', err);
      res.status(500).json({ success: false, message: 'Failed to update user' });
    }
  }
}