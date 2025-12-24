const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');

const app = express();
const port = process.env.PORT || 5001;

// Middleware
app.use(cors());
app.use(express.json());

// Database configuration
const dbConfig = {
  host: process.env.DB_HOST || 'database-prod',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'lpi_production_db',
  user: process.env.DB_USER || 'lpi_user',
  password: process.env.DB_PASSWORD || 'AbataSecure123!',
  connectionTimeoutMillis: 5000,
  max: 20,
  idleTimeoutMillis: 30000
};

console.log('🚀 LPI Production Backend starting...');
console.log('📍 Database:', dbConfig.database);

let pool;
let dbConnected = false;
let retryCount = 0;
const maxRetries = 10;

// Retry connection function
const connectWithRetry = async () => {
  while (retryCount < maxRetries && !dbConnected) {
    try {
      console.log(`Attempting database connection (attempt ${retryCount + 1}/${maxRetries})...`);
      
      pool = new Pool(dbConfig);
      const client = await pool.connect();
      
      console.log('✅ Production Database connected successfully!');
      
      // Test query
      await client.query('SELECT 1');
      client.release();
      
      dbConnected = true;
      console.log('✅ Database connection established');
      return;
      
    } catch (error) {
      retryCount++;
      console.log(`❌ Connection attempt ${retryCount} failed:`, error.message);
      
      if (retryCount < maxRetries) {
        console.log(`⏳ Retrying in 5 seconds...`);
        await new Promise(resolve => setTimeout(resolve, 5000));
      } else {
        console.log('❌ Max retries reached. Database connection failed.');
        dbConnected = false;
      }
    }
  }
};

// Initialize connection with retry
const initializeDatabase = async () => {
  await connectWithRetry();
};

// Simple health check endpoint
app.get('/health', async (req, res) => {
  if (dbConnected) {
    try {
      await pool.query('SELECT 1');
      res.json({
        status: 'OK',
        message: 'Production Backend and Database are healthy',
        database: 'connected',
        retry_count: retryCount,
        timestamp: new Date().toISOString()
      });
    } catch (error) {
      res.json({
        status: 'OK',
        message: 'Backend running (database connection lost)',
        database: 'disconnected',
        error: error.message,
        timestamp: new Date().toISOString()
      });
    }
  } else {
    res.json({
      status: 'OK',
      message: 'Backend running (waiting for database)',
      database: 'connecting',
      retry_count: retryCount,
      timestamp: new Date().toISOString()
    });
  }
});

// Menu endpoint
app.get('/api/menu', async (req, res) => {
  if (dbConnected) {
    try {
      const result = await pool.query(`
        SELECT id, nama, link, banner, icon, category
        FROM menu_prod 
        ORDER BY id
      `);
      
      return res.json({
        success: true,
        data: result.rows,
        count: result.rows.length,
        source: 'production_database',
        environment: 'production'
      });
    } catch (error) {
      console.log('Database query error:', error.message);
    }
  }

  // Fallback data
  res.json({
    success: true,
    data: [
      { id: 1, nama: 'Driver PROD', link: '#', banner: '', icon: '' },
      { id: 2, nama: 'Room PROD', link: '#', banner: '', icon: '' }
    ],
    count: 2,
    source: 'static_fallback',
    environment: 'production'
  });
});

// Start server first, then initialize database
app.listen(port, '0.0.0.0', () => {
  console.log(`✅ LPI Production Backend running on port ${port}`);
  console.log(`📍 Health endpoint: http://localhost:${port}/health`);
  
  // Initialize database in background
  initializeDatabase().then(() => {
    console.log('📍 Database initialization completed');
  }).catch(err => {
    console.log('📍 Database initialization failed:', err.message);
  });
});

// Docker healthcheck endpoint (simple, always returns 200)
app.get('/docker-health', (req, res) => {
  res.status(200).send('OK');
});

// Update existing health endpoint
app.get('/health', async (req, res) => {
  if (dbConnected) {
    try {
      await pool.query('SELECT 1');
      res.json({
        status: 'OK',
        message: 'Production Backend and Database are healthy',
        database: 'connected',
        retry_count: retryCount,
        timestamp: new Date().toISOString()
      });
    } catch (error) {
      res.status(503).json({  // Return 503 for healthcheck failure
        status: 'ERROR',
        message: 'Database connection lost',
        error: error.message,
        timestamp: new Date().toISOString()
      });
    }
  } else {
    res.status(503).json({
      status: 'CONNECTING',
      message: 'Backend starting up...',
      database: 'connecting',
      retry_count: retryCount,
      timestamp: new Date().toISOString()
    });
  }
});
