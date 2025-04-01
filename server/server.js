const express = require('express');
const cors = require('cors');
const db = require('./config/database');
const routes = require('./routes');

const cron = require('node-cron');
const recurringTransactionService = require('./services/recurring_transaction.service');

require('dotenv').config();

const app = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(cors({origin: '*'}));
app.use(express.json()); // Parse JSON body

// Routes
app.use('/api', routes);

// Test database connection (optional)
app.get('/api/test-db', (req, res) => {
  db.query('SELECT 1', (err, results) => {
    if (err) {
      res.status(500).json({ error: 'Lỗi kết nối database' });
    } else {
      res.json({ message: 'Kết nối database thành công!' });
    }
  });
});

// Lên lịch chạy hàm createTransactionsFromDueRecurringTransactions() vào lúc 00:00 mỗi ngày
cron.schedule('0 0 * * *', async () => {
    console.log('Running createTransactionsFromDueRecurringTransactions()');
    try {
      await recurringTransactionService.createTransactionsFromDueRecurringTransactions();
      console.log('Transactions created successfully from due recurring transactions.');
    } catch (error) {
      console.error('Error creating transactions from due recurring transactions:', error);
    }
  });
  
  app.listen(port, () => {
    console.log(`Server đang chạy tại cổng ${port}`);
  });