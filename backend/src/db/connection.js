// ============================================================
// 📁 src/db/connection.js
// Configuración de la conexión a PostgreSQL
// Soporta:
//  - DATABASE_URL (Render, Railway, Heroku)
//  - Variables individuales (desarrollo local con .env)
// ============================================================

const { Pool } = require('pg');
require('dotenv').config();

// Detectar si estamos en producción (Render inyecta DATABASE_URL)
const connectionString = process.env.DATABASE_URL;

let poolConfig;

if (connectionString) {
  // Modo producción (Render): usar DATABASE_URL completa
  poolConfig = {
    connectionString: connectionString,
    ssl: { rejectUnauthorized: false }, // Requerido por Render
    max: 20,
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 5000,
  };
} else {
  // Modo desarrollo local: usar variables del .env
  poolConfig = {
    host: process.env.DB_HOST,
    port: parseInt(process.env.DB_PORT, 10),
    database: process.env.DB_NAME,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    max: 20,
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 2000,
  };
}

const pool = new Pool(poolConfig);

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