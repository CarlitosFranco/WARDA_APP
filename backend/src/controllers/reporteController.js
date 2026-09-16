// ============================================================
// 📁 src/controllers/reporteController.js
// Lógica de reportes/incidentes
// ============================================================

const { query } = require('../db/connection');

// ============================================================
// 🛠️ HELPER: Formatear reporte (snake_case → camelCase)
// ============================================================
const formatearReporte = (row) => ({
  id: row.id,
  usuarioId: row.usuario_id,
  titulo: row.titulo,
  descripcion: row.descripcion,
  tipo: row.tipo,
  estado: row.estado,
  fecha: row.fecha,
  ubicacion: row.ubicacion,
  latitud: row.latitud,
  longitud: row.longitud,
  imagenes: row.imagenes ? row.imagenes.split('|') : null,
  createdAt: row.created_at,
});

// ============================================================
// 📋 GET /api/reportes
// Listar TODOS los reportes (para el mapa)
// ============================================================
const getAllReportes = async (req, res, next) => {
  try {
    const result = await query(
      `SELECT * FROM reportes 
       ORDER BY fecha DESC 
       LIMIT 500` // Limitar a 500 para no sobrecargar
    );

    res.json({
      success: true,
      data: {
        reportes: result.rows.map(formatearReporte),
        total: result.rows.length,
      },
    });
  } catch (error) {
    next(error);
  }
};

// ============================================================
// 👤 GET /api/reportes/usuario/:usuarioId
// Listar reportes de un usuario específico
// ============================================================
const getReportesByUsuario = async (req, res, next) => {
  try {
    const { usuarioId } = req.params;

    const result = await query(
      `SELECT * FROM reportes 
       WHERE usuario_id = $1 
       ORDER BY fecha DESC`,
      [usuarioId]
    );

    res.json({
      success: true,
      data: {
        reportes: result.rows.map(formatearReporte),
        total: result.rows.length,
      },
    });
  } catch (error) {
    next(error);
  }
};

// ============================================================
// 🔍 GET /api/reportes/:id
// Obtener un reporte específico por ID
// ============================================================
const getReporteById = async (req, res, next) => {
  try {
    const { id } = req.params;

    const result = await query('SELECT * FROM reportes WHERE id = $1', [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: { message: 'Reporte no encontrado' },
      });
    }

    res.json({
      success: true,
      data: {
        reporte: formatearReporte(result.rows[0]),
      },
    });
  } catch (error) {
    next(error);
  }
};

// ============================================================
// ✏️ POST /api/reportes (Protegida)
// Crear un nuevo reporte
// ============================================================
const createReporte = async (req, res, next) => {
  try {
    const {
      id,
      titulo,
      descripcion,
      tipo,
      estado,
      ubicacion,
      latitud,
      longitud,
      imagenes,
    } = req.body;

    // Validaciones
    if (!id || !titulo || !descripcion || !tipo) {
      return res.status(400).json({
        success: false,
        error: { message: 'Faltan campos obligatorios (id, titulo, descripcion, tipo)' },
      });
    }

    // El usuario_id viene del token JWT (req.usuario.id)
    const usuarioId = req.usuario.id;

    // Convertir array de imágenes a string separado por |
    const imagenesStr = Array.isArray(imagenes) && imagenes.length > 0
      ? imagenes.join('|')
      : null;

    const result = await query(
      `INSERT INTO reportes 
        (id, usuario_id, titulo, descripcion, tipo, estado, ubicacion, latitud, longitud, imagenes)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
       RETURNING *`,
      [
        id,
        usuarioId,
        titulo,
        descripcion,
        tipo,
        estado || 'pendiente',
        ubicacion || null,
        latitud || null,
        longitud || null,
        imagenesStr,
      ]
    );

    res.status(201).json({
      success: true,
      message: '✅ Reporte creado exitosamente',
      data: {
        reporte: formatearReporte(result.rows[0]),
      },
    });
  } catch (error) {
    next(error);
  }
};

// ============================================================
// 🔄 PUT /api/reportes/:id (Protegida)
// Actualizar un reporte
// ============================================================
const updateReporte = async (req, res, next) => {
  try {
    const { id } = req.params;
    const {
      titulo,
      descripcion,
      tipo,
      estado,
      ubicacion,
      latitud,
      longitud,
      imagenes,
    } = req.body;

    // Verificar que el reporte existe
    const existe = await query('SELECT * FROM reportes WHERE id = $1', [id]);
    if (existe.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: { message: 'Reporte no encontrado' },
      });
    }

    const reporteActual = existe.rows[0];

    // Verificar que el usuario sea el dueño (o admin)
    if (reporteActual.usuario_id !== req.usuario.id) {
      return res.status(403).json({
        success: false,
        error: { message: 'No tienes permiso para editar este reporte' },
      });
    }

    // Convertir imágenes
    const imagenesStr = Array.isArray(imagenes) && imagenes.length > 0
      ? imagenes.join('|')
      : reporteActual.imagenes;

    const result = await query(
      `UPDATE reportes 
       SET titulo = $1, descripcion = $2, tipo = $3, estado = $4,
           ubicacion = $5, latitud = $6, longitud = $7, imagenes = $8,
           updated_at = CURRENT_TIMESTAMP
       WHERE id = $9
       RETURNING *`,
      [
        titulo || reporteActual.titulo,
        descripcion || reporteActual.descripcion,
        tipo || reporteActual.tipo,
        estado || reporteActual.estado,
        ubicacion !== undefined ? ubicacion : reporteActual.ubicacion,
        latitud !== undefined ? latitud : reporteActual.latitud,
        longitud !== undefined ? longitud : reporteActual.longitud,
        imagenesStr,
        id,
      ]
    );

    res.json({
      success: true,
      message: '✅ Reporte actualizado',
      data: {
        reporte: formatearReporte(result.rows[0]),
      },
    });
  } catch (error) {
    next(error);
  }
};

// ============================================================
// 🗑️ DELETE /api/reportes/:id (Protegida)
// Eliminar un reporte
// ============================================================
const deleteReporte = async (req, res, next) => {
  try {
    const { id } = req.params;

    // Verificar que el reporte existe
    const existe = await query('SELECT * FROM reportes WHERE id = $1', [id]);
    if (existe.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: { message: 'Reporte no encontrado' },
      });
    }

    // Verificar que el usuario sea el dueño
    if (existe.rows[0].usuario_id !== req.usuario.id) {
      return res.status(403).json({
        success: false,
        error: { message: 'No tienes permiso para eliminar este reporte' },
      });
    }

    await query('DELETE FROM reportes WHERE id = $1', [id]);

    res.json({
      success: true,
      message: '✅ Reporte eliminado',
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getAllReportes,
  getReportesByUsuario,
  getReporteById,
  createReporte,
  updateReporte,
  deleteReporte,
};