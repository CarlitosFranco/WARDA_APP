// ============================================================
// 📁 src/db/connection.js
// Configuración de la conexión a PostgreSQL
// ============================================================

const { Pool } = require('pg');
require('dotenv').config();

// Pool de conexiones (reutiliza conexiones para mejor rendimiento)
const pool = new Pool({
  host: process.env.DB_HOST,
  port: parseInt(process.env.DB_PORT, 10),
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  max: 20,                 // Máximo de conexiones en el pool
  idleTimeoutMillis: 30000, // 30s antes de cerrar conexiones inactivas
  connectionTimeoutMillis: 2000, // 2s timeout al conectar
});

// Evento: cuando se conecta exitosamente
pool.on('connect', () => {
  console.log('✅ PostgreSQL conectado');
});

// Evento: cuando hay un error en una conexión inactiva
pool.on('error', (err) => {
  console.error('❌ Error en PostgreSQL:', err.message);
  process.exit(-1);
});

// Test rápido de conexión
const testConnection = async () => {
  try {
    const client = await pool.connect();
    const result = await client.query('SELECT NOW() AS ahora');
    console.log('🕒 Hora del servidor BD:', result.rows[0].ahora);
    client.release();
    return true;
  } catch (error) {
    console.error('❌ No se pudo conectar a PostgreSQL:', error.message);
    return false;
  }
};

module.exports = {
  pool,
  query: (text, params) => pool.query(text, params),
  testConnection,
};