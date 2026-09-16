// ============================================================
// 📁 src/controllers/contactoController.js
// Lógica de contactos de emergencia
// ============================================================

const { query } = require('../db/connection');

// ============================================================
// 🛠️ HELPER: Formatear contacto (snake_case → camelCase)
// ============================================================
const formatearContacto = (row) => ({
  id: row.id,
  usuarioId: row.usuario_id,
  nombre: row.nombre,
  telefono: row.telefono,
  relacion: row.relacion,
  createdAt: row.created_at,
});

// ============================================================
// 📋 GET /api/contactos
// Listar contactos del usuario autenticado
// ============================================================
const getContactos = async (req, res, next) => {
  try {
    // req.usuario.id viene del middleware verifyToken
    const usuarioId = req.usuario.id;

    const result = await query(
      `SELECT * FROM contactos_emergencia 
       WHERE usuario_id = $1 
       ORDER BY created_at ASC`,
      [usuarioId]
    );

    res.json({
      success: true,
      data: {
        contactos: result.rows.map(formatearContacto),
        total: result.rows.length,
      },
    });
  } catch (error) {
    next(error);
  }
};

// ============================================================
// 🔍 GET /api/contactos/:id
// Obtener un contacto específico
// ============================================================
const getContactoById = async (req, res, next) => {
  try {
    const { id } = req.params;
    const usuarioId = req.usuario.id;

    const result = await query(
      'SELECT * FROM contactos_emergencia WHERE id = $1 AND usuario_id = $2',
      [id, usuarioId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: { message: 'Contacto no encontrado' },
      });
    }

    res.json({
      success: true,
      data: {
        contacto: formatearContacto(result.rows[0]),
      },
    });
  } catch (error) {
    next(error);
  }
};

// ============================================================
// ➕ POST /api/contactos (Protegida)
// Crear un nuevo contacto de emergencia
// ============================================================
const createContacto = async (req, res, next) => {
  try {
    const { id, nombre, telefono, relacion } = req.body;

    // Validaciones
    if (!id || !nombre || !telefono || !relacion) {
      return res.status(400).json({
        success: false,
        error: { message: 'Faltan campos obligatorios (id, nombre, telefono, relacion)' },
      });
    }

    const usuarioId = req.usuario.id;

    // Verificar que el ID no exista
    const existe = await query('SELECT id FROM contactos_emergencia WHERE id = $1', [id]);
    if (existe.rows.length > 0) {
      return res.status(409).json({
        success: false,
        error: { message: 'Ya existe un contacto con ese ID' },
      });
    }

    const result = await query(
      `INSERT INTO contactos_emergencia 
        (id, usuario_id, nombre, telefono, relacion)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING *`,
      [id, usuarioId, nombre.trim(), telefono.trim(), relacion.trim()]
    );

    res.status(201).json({
      success: true,
      message: '✅ Contacto agregado exitosamente',
      data: {
        contacto: formatearContacto(result.rows[0]),
      },
    });
  } catch (error) {
    next(error);
  }
};

// ============================================================
// 🔄 PUT /api/contactos/:id (Protegida)
// Actualizar un contacto
// ============================================================
const updateContacto = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { nombre, telefono, relacion } = req.body;
    const usuarioId = req.usuario.id;

    // Verificar que el contacto existe y pertenece al usuario
    const existe = await query(
      'SELECT * FROM contactos_emergencia WHERE id = $1 AND usuario_id = $2',
      [id, usuarioId]
    );

    if (existe.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: { message: 'Contacto no encontrado' },
      });
    }

    const contactoActual = existe.rows[0];

    const result = await query(
      `UPDATE contactos_emergencia 
       SET nombre = $1, telefono = $2, relacion = $3
       WHERE id = $4
       RETURNING *`,
      [
        nombre ? nombre.trim() : contactoActual.nombre,
        telefono ? telefono.trim() : contactoActual.telefono,
        relacion ? relacion.trim() : contactoActual.relacion,
        id,
      ]
    );

    res.json({
      success: true,
      message: '✅ Contacto actualizado',
      data: {
        contacto: formatearContacto(result.rows[0]),
      },
    });
  } catch (error) {
    next(error);
  }
};

// ============================================================
// 🗑️ DELETE /api/contactos/:id (Protegida)
// Eliminar un contacto
// ============================================================
const deleteContacto = async (req, res, next) => {
  try {
    const { id } = req.params;
    const usuarioId = req.usuario.id;

    // Verificar que el contacto existe y pertenece al usuario
    const existe = await query(
      'SELECT id FROM contactos_emergencia WHERE id = $1 AND usuario_id = $2',
      [id, usuarioId]
    );

    if (existe.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: { message: 'Contacto no encontrado' },
      });
    }

    await query('DELETE FROM contactos_emergencia WHERE id = $1', [id]);

    res.json({
      success: true,
      message: '✅ Contacto eliminado',
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getContactos,
  getContactoById,
  createContacto,
  updateContacto,
  deleteContacto,
};