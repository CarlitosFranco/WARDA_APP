// ============================================================
// 📁 src/controllers/authController.js
// Lógica de registro, login y perfil
// ============================================================

const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { query } = require('../db/connection');

// ============================================================
// 🛠️ HELPERS
// ============================================================

// Generar token JWT
const generarToken = (usuario) => {
  return jwt.sign(
    { id: usuario.id, email: usuario.email },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
  );
};

// Convertir usuario de BD (snake_case) a respuesta API (camelCase)
const formatearUsuario = (row) => ({
  id: row.id,
  nombre: row.nombre,
  email: row.email,
  telefono: row.telefono,
  fotoUrl: row.foto_url,
  notificacionesActivas: row.notificaciones_activas,
  ubicacionCompartida: row.ubicacion_compartida,
  createdAt: row.created_at,
});

// ============================================================
// 📝 POST /api/auth/register
// Registrar un nuevo usuario
// ============================================================
const register = async (req, res, next) => {
  try {
    const { id, nombre, email, telefono, password, fotoUrl } = req.body;

    // Validaciones básicas
    if (!id || !nombre || !email || !telefono || !password) {
      return res.status(400).json({
        success: false,
        error: { message: 'Faltan campos obligatorios (id, nombre, email, telefono, password)' },
      });
    }

    if (password.length < 6) {
      return res.status(400).json({
        success: false,
        error: { message: 'La contraseña debe tener al menos 6 caracteres' },
      });
    }

    // Verificar si el email ya existe
    const existe = await query('SELECT id FROM usuarios WHERE email = $1', [email]);
    if (existe.rows.length > 0) {
      return res.status(409).json({
        success: false,
        error: { message: 'El email ya está registrado' },
      });
    }

    // Cifrar la contraseña
    const passwordHash = await bcrypt.hash(password, 10);

    // Insertar usuario
    const result = await query(
      `INSERT INTO usuarios 
        (id, nombre, email, telefono, foto_url, password_hash, notificaciones_activas, ubicacion_compartida)
       VALUES ($1, $2, $3, $4, $5, $6, TRUE, TRUE)
       RETURNING *`,
      [id, nombre, email, telefono, fotoUrl || null, passwordHash]
    );

    const usuario = result.rows[0];
    const token = generarToken(usuario);

    res.status(201).json({
      success: true,
      message: '✅ Usuario registrado exitosamente',
      data: {
        usuario: formatearUsuario(usuario),
        token,
      },
    });
  } catch (error) {
    next(error);
  }
};

// ============================================================
// 🔐 POST /api/auth/login
// Iniciar sesión
// ============================================================
const login = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        error: { message: 'Email y contraseña son obligatorios' },
      });
    }

    // Buscar usuario por email
    const result = await query('SELECT * FROM usuarios WHERE email = $1', [email]);
    if (result.rows.length === 0) {
      return res.status(401).json({
        success: false,
        error: { message: 'Email o contraseña incorrectos' },
      });
    }

    const usuario = result.rows[0];

    // Comparar contraseñas
    const passwordOk = await bcrypt.compare(password, usuario.password_hash);
    if (!passwordOk) {
      return res.status(401).json({
        success: false,
        error: { message: 'Email o contraseña incorrectos' },
      });
    }

    const token = generarToken(usuario);

    res.json({
      success: true,
      message: '✅ Sesión iniciada',
      data: {
        usuario: formatearUsuario(usuario),
        token,
      },
    });
  } catch (error) {
    next(error);
  }
};

// ============================================================
// 👤 GET /api/auth/me (Protegido)
// Obtener el usuario autenticado
// ============================================================
const getMe = async (req, res, next) => {
  try {
    // req.usuario viene del middleware verifyToken
    const result = await query('SELECT * FROM usuarios WHERE id = $1', [req.usuario.id]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: { message: 'Usuario no encontrado' },
      });
    }

    res.json({
      success: true,
      data: {
        usuario: formatearUsuario(result.rows[0]),
      },
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  register,
  login,
  getMe,
};