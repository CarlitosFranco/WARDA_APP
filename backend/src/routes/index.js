// ============================================================
// 📁 src/routes/index.js
// Enrutador principal
// ============================================================

const express = require('express');
const router = express.Router();

// ============================================================
// 🏥 HEALTH CHECK
// ============================================================
router.get('/health', (req, res) => {
  res.json({
    success: true,
    message: '🚀 WARDA API funcionando correctamente',
    timestamp: new Date().toISOString(),
    version: '1.0.0',
  });
});

// ============================================================
// 🔐 AUTENTICACIÓN
// ============================================================
router.use('/auth', require('./auth.routes'));

// ============================================================
// 📝 REPORTES
// ============================================================
router.use('/reportes', require('./reporte.routes'));

// ============================================================
// 📞 CONTACTOS DE EMERGENCIA
// ============================================================
router.use('/contactos', require('./contacto.routes'));

// ============================================================
// 📤 UPLOADS (SUBIDA DE IMÁGENES)
// ============================================================
router.use('/uploads', require('./upload.routes'));

module.exports = router;