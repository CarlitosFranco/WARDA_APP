// ============================================================
// 📁 src/middlewares/uploadMiddleware.js
// Configuración de multer para subida de imágenes
// ============================================================

const multer = require('multer');
const path = require('path');
const fs = require('fs');

// ============================================================
// 📂 ASEGURAR QUE LA CARPETA uploads/ EXISTA
// ============================================================
const uploadDir = path.join(__dirname, '..', '..', 'uploads');
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// ============================================================
// 💾 CONFIGURACIÓN DEL ALMACENAMIENTO
// ============================================================
const storage = multer.diskStorage({
  // Carpeta destino
  destination: (req, file, cb) => {
    cb(null, uploadDir);
  },

  // Nombre del archivo: timestamp_random.ext
  filename: (req, file, cb) => {
    const timestamp = Date.now();
    const random = Math.round(Math.random() * 1e9);
    const ext = path.extname(file.originalname).toLowerCase();
    cb(null, `foto_${timestamp}_${random}${ext}`);
  },
});

// ============================================================
// 🔍 FILTRO DE ARCHIVOS (solo imágenes)
// ============================================================
const fileFilter = (req, file, cb) => {
  const allowedTypes = /jpeg|jpg|png|gif|webp/;
  const ext = path.extname(file.originalname).toLowerCase();
  const mime = file.mimetype;

  const extValida = allowedTypes.test(ext);
  const mimeValido = allowedTypes.test(mime);

  if (extValida && mimeValido) {
    cb(null, true);
  } else {
    cb(
      new Error(
        'Solo se permiten imágenes (jpeg, jpg, png, gif, webp)'
      ),
      false
    );
  }
};

// ============================================================
// ⚙️ INSTANCIA DE MULTER
// ============================================================
const upload = multer({
  storage,
  fileFilter,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5 MB máximo por archivo
    files: 5,                  // Máximo 5 archivos por petición
  },
});

// ============================================================
// 📤 EXPORTS
// ============================================================

// Subir una sola imagen (campo 'foto')
const uploadSingle = upload.single('foto');

// Subir múltiples imágenes (campo 'fotos', máximo 5)
const uploadMultiple = upload.array('fotos', 5);

module.exports = {
  uploadSingle,
  uploadMultiple,
  uploadDir,
};