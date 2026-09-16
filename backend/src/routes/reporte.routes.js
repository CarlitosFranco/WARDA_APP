// ============================================================
// 📁 src/routes/reporte.routes.js
// Rutas: /api/reportes/*
// ============================================================

const express = require('express');
const router = express.Router();

const {
  getAllReportes,
  getReportesByUsuario,
  getReporteById,
  createReporte,
  updateReporte,
  deleteReporte,
} = require('../controllers/reporteController');

const { verifyToken } = require('../middlewares/auth');

// ============================================================
// 🌍 RUTAS PÚBLICAS (para el mapa)
// ============================================================

// GET /api/reportes → Todos los reportes (para el mapa)
router.get('/', getAllReportes);

// GET /api/reportes/usuario/:usuarioId → Reportes de un usuario
router.get('/usuario/:usuarioId', getReportesByUsuario);

// GET /api/reportes/:id → Un reporte por ID
// ⚠️ Esta ruta va AL FINAL para que no capture /usuario/...
router.get('/:id', getReporteById);

// ============================================================
// 🔒 RUTAS PROTEGIDAS (requieren token JWT)
// ============================================================

// POST /api/reportes → Crear reporte
router.post('/', verifyToken, createReporte);

// PUT /api/reportes/:id → Actualizar reporte
router.put('/:id', verifyToken, updateReporte);

// DELETE /api/reportes/:id → Eliminar reporte
router.delete('/:id', verifyToken, deleteReporte);

module.exports = router;