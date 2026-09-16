// ============================================================
// 📁 backend/server.js
// Punto de entrada del servidor WARDA
// ============================================================

require('dotenv').config();

const express = require('express');
const cors = require('cors');

const { testConnection } = require('./src/db/connection');
const routes = require('./src/routes');
const { notFound, errorHandler } = require('./src/middlewares/errorHandler');

// ============================================================
// 🚀 INICIALIZAR EXPRESS
// ============================================================
const app = express();
const PORT = process.env.PORT || 3000;

// ============================================================
// 🔧 MIDDLEWARES GLOBALES
// ============================================================
app.use(cors()); // Permitir peticiones desde otros orígenes (Flutter)
app.use(express.json({ limit: '10mb' })); // Parsear JSON
app.use(express.urlencoded({ extended: true })); // Parsear formularios

// Logger simple de peticiones
app.use((req, res, next) => {
  const timestamp = new Date().toLocaleTimeString();
  console.log(`[${timestamp}] ${req.method} ${req.originalUrl}`);
  next();
});

// ============================================================
// 🛣️ RUTAS
// ============================================================
app.use('/api', routes);

// Ruta raíz (por si abren http://localhost:3000)
app.get('/', (req, res) => {
  res.json({
    success: true,
    message: '🚀 Bienvenido a WARDA API',
    endpoints: {
      health: '/api/health',
      auth: '/api/auth',
      reportes: '/api/reportes',
      contactos: '/api/contactos',
    },
  });
});

// ============================================================
// ⚠️ MANEJO DE ERRORES (SIEMPRE AL FINAL)
// ============================================================
app.use(notFound);
app.use(errorHandler);

// ============================================================
// 🎬 INICIAR SERVIDOR
// ============================================================
const startServer = async () => {
  console.log('\n═══════════════════════════════════════════');
  console.log('🚀 INICIANDO WARDA BACKEND');
  console.log('═══════════════════════════════════════════\n');

  // 1. Verificar conexión a la BD
  const dbOk = await testConnection();
  if (!dbOk) {
    console.error('❌ No se pudo conectar a la base de datos. Abortando...');
    process.exit(1);
  }

  // 2. Iniciar servidor
  app.listen(PORT, () => {
    console.log('\n═══════════════════════════════════════════');
    console.log(`✅ Servidor corriendo en http://localhost:${PORT}`);
    console.log(`📚 Health check: http://localhost:${PORT}/api/health`);
    console.log(`🌍 Modo: ${process.env.NODE_ENV || 'development'}`);
    console.log('═══════════════════════════════════════════\n');
  });
};

// Manejo de errores no capturados
process.on('unhandledRejection', (err) => {
  console.error('❌ Unhandled Rejection:', err.message);
  process.exit(1);
});

// Arrancar
startServer();