import { ActivityLog } from '../models/ActivityLog.js';

export class ActivityLogController {
  static async getLogs(req, res) {
    try {
      const { page = 1, limit = 20, search, startDate, endDate } = req.query;
      const offset = (page - 1) * limit;

      const result = await ActivityLog.findAll(
        { search, startDate, endDate }, 
        limit, 
        offset
      );

      res.json({
        success: true,
        data: result.logs,
        pagination: {
            total: result.total,
            page: parseInt(page),
            limit: parseInt(limit),
            totalPages: Math.ceil(result.total / limit)
        }
      });
    } catch (error) {
      console.error('Fetch logs error:', error);
      res.status(500).json({ success: false, message: 'Failed to fetch logs' });
    }
  }

  // [NEW] Get Stats
  static async getStats(req, res) {
    try {
      const total = await ActivityLog.countAll();
      res.json({ success: true, data: { total } });
    } catch (error) {
      res.status(500).json({ success: false, message: error.message });
    }
  }

  // [NEW] Prune Logs
  static async pruneLogs(req, res) {
    try {
      const { retentionDays } = req.body;
      if (!retentionDays || isNaN(retentionDays)) {
         return res.status(400).json({ success: false, message: 'Invalid retention period' });
      }

      const deletedCount = await ActivityLog.prune(retentionDays);
      
      // Log the maintenance action itself!
      await ActivityLog.create({
        userId: req.body.userId || null,
        username: req.body.username || 'Admin',
        action: 'System Maintenance',
        details: `Pruned ${deletedCount} log records older than ${retentionDays} days.`,
        ipAddress: req.ip
      });

      res.json({ success: true, message: `Successfully deleted ${deletedCount} old records.` });
    } catch (error) {
      console.error('Prune error:', error);
      res.status(500).json({ success: false, message: 'Failed to prune logs' });
    }
  }
}