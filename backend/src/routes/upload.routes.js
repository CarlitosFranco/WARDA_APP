// ============================================================
// 📁 src/routes/upload.routes.js
// Rutas: /api/uploads/*
// ============================================================

const express = require('express');
const router = express.Router();

const {
  uploadImagen,
  uploadMultiples,
  deleteImagen,
} = require('../controllers/uploadController');

const {
  uploadSingle,
  uploadMultiple,
} = require('../middlewares/uploadMiddleware');

const { verifyToken } = require('../middlewares/auth');

// Todas las rutas requieren autenticación
router.use(verifyToken);

// POST /api/uploads → Subir UNA imagen
router.post('/', uploadSingle, uploadImagen);

// POST /api/uploads/multiple → Subir MÚLTIPLES (hasta 5)
router.post('/multiple', uploadMultiple, uploadMultiples);

// DELETE /api/uploads/:filename → Eliminar una imagen
router.delete('/:filename', deleteImagen);

module.exports = router;