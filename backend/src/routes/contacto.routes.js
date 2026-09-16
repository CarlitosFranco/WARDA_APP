// ============================================================
// 📁 src/routes/contacto.routes.js
// Rutas: /api/contactos/*
// Todas requieren autenticación
// ============================================================

const express = require('express');
const router = express.Router();

const {
  getContactos,
  getContactoById,
  createContacto,
  updateContacto,
  deleteContacto,
} = require('../controllers/contactoController');

const { verifyToken } = require('../middlewares/auth');

// Todas las rutas requieren token
router.use(verifyToken);

// GET /api/contactos → Listar mis contactos
router.get('/', getContactos);

// GET /api/contactos/:id → Obtener uno
router.get('/:id', getContactoById);

// POST /api/contactos → Crear
router.post('/', createContacto);

// PUT /api/contactos/:id → Actualizar
router.put('/:id', updateContacto);

// DELETE /api/contactos/:id → Eliminar
router.delete('/:id', deleteContacto);

module.exports = router;