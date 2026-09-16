// ============================================================
// 📁 src/middlewares/auth.js
// Middleware para verificar tokens JWT
// ============================================================

const jwt = require('jsonwebtoken');

const verifyToken = (req, res, next) => {
  try {
    // Buscar el token en el header Authorization
    const authHeader = req.headers.authorization;

    if (!authHeader) {
      return res.status(401).json({
        success: false,
        error: { message: 'Token no proporcionado' },
      });
    }

    // Formato esperado: "Bearer <token>"
    const parts = authHeader.split(' ');
    if (parts.length !== 2 || parts[0] !== 'Bearer') {
      return res.status(401).json({
        success: false,
        error: { message: 'Formato de token inválido' },
      });
    }

    const token = parts[1];

    // Verificar el token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.usuario = decoded; // { id, email }
    next();
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        success: false,
        error: { message: 'Token expirado. Inicia sesión de nuevo.' },
      });
    }
    return res.status(401).json({
      success: false,
      error: { message: 'Token inválido' },
    });
  }
};

module.exports = { verifyToken };