// ============================================================
// 📁 src/controllers/uploadController.js
// Manejo de subida de imágenes
// ============================================================

const path = require('path');

// ============================================================
// 📤 POST /api/uploads
// Subir una imagen
// ============================================================
const uploadImagen = async (req, res, next) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        error: { message: 'No se recibió ningún archivo' },
      });
    }

    // Construir la URL pública de la imagen
    const baseUrl = `${req.protocol}://${req.get('host')}`;
    const url = `${baseUrl}/uploads/${req.file.filename}`;

    res.status(201).json({
      success: true,
      message: '✅ Imagen subida exitosamente',
      data: {
        filename: req.file.filename,
        originalName: req.file.originalname,
        size: req.file.size,
        mimetype: req.file.mimetype,
        url,
      },
    });
  } catch (error) {
    next(error);
  }
};

// ============================================================
// 📤 POST /api/uploads/multiple
// Subir hasta 5 imágenes
// ============================================================
const uploadMultiples = async (req, res, next) => {
  try {
    if (!req.files || req.files.length === 0) {
      return res.status(400).json({
        success: false,
        error: { message: 'No se recibieron archivos' },
      });
    }

    const baseUrl = `${req.protocol}://${req.get('host')}`;

    const archivos = req.files.map((file) => ({
      filename: file.filename,
      originalName: file.originalname,
      size: file.size,
      mimetype: file.mimetype,
      url: `${baseUrl}/uploads/${file.filename}`,
    }));

    res.status(201).json({
      success: true,
      message: `✅ ${archivos.length} imágenes subidas`,
      data: {
        archivos,
        total: archivos.length,
      },
    });
  } catch (error) {
    next(error);
  }
};

// ============================================================
// 🗑️ DELETE /api/uploads/:filename
// Eliminar una imagen
// ============================================================
const deleteImagen = async (req, res, next) => {
  try {
    const { filename } = req.params;
    const fs = require('fs');
    const path = require('path');

    // Prevenir path traversal
    if (filename.includes('..') || filename.includes('/')) {
      return res.status(400).json({
        success: false,
        error: { message: 'Nombre de archivo inválido' },
      });
    }

    const filePath = path.join(
      __dirname,
      '..',
      '..',
      'uploads',
      filename
    );

    if (!fs.existsSync(filePath)) {
      return res.status(404).json({
        success: false,
        error: { message: 'Archivo no encontrado' },
      });
    }

    fs.unlinkSync(filePath);

    res.json({
      success: true,
      message: '✅ Imagen eliminada',
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  uploadImagen,
  uploadMultiples,
  deleteImagen,
};