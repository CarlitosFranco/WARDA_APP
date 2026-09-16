// ============================================================
// 📁 src/middlewares/errorHandler.js
// Manejo centralizado de errores
// ============================================================

// Middleware para rutas no encontradas (404)
const notFound = (req, res, next) => {
  const error = new Error(`Ruta no encontrada: ${req.originalUrl}`);
  error.status = 404;
  next(error);
};

// Middleware para manejo general de errores
const errorHandler = (err, req, res, next) => {
  const statusCode = err.status || err.statusCode || 500;

  console.error(`❌ Error [${statusCode}]:`, err.message);

  res.status(statusCode).json({
    success: false,
    error: {
      message: err.message || 'Error interno del servidor',
      ...(process.env.NODE_ENV === 'development' && { stack: err.stack }),
    },
  });
};

module.exports = {
  notFound,
  errorHandler,
};