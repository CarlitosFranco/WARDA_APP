// ============================================================
// 📁 src/routes/auth.routes.js
// Rutas: /api/auth/*
// ============================================================

const express = require('express');
const router = express.Router();

const { register, login, getMe } = require('../controllers/authController');
const { verifyToken } = require('../middlewares/auth');

// POST /api/auth/register
router.post('/register', register);

// POST /api/auth/login
router.post('/login', login);

// GET /api/auth/me (protegida)
router.get('/me', verifyToken, getMe);

module.exports = router;