// ============================================================
// 📁 utils/constants.dart
// Constantes globales de WARDA
// ============================================================

class AppConstants {
  // ============================================================
  // 🌐 API
  // ============================================================
  // 🚀 PRODUCCIÓN (Render - backend en la nube):
  //    El backend está desplegado en Render y es accesible desde
  //    cualquier red del mundo (WiFi, datos móviles, etc.)
  //
  // Para DESARROLLO local (backend en tu PC):
  //   - Emulador Android: 'http://10.0.2.2:3000/api'
  //   - Celular físico:   'http://192.168.0.4:3000/api'
  //   - Web (Chrome):     'http://localhost:3000/api'
  // ============================================================
  static const String apiUrl = 'https://warda-backend-e3bk.onrender.com/api';

  // ============================================================
  // 💾 PREFERENCIAS (SharedPreferences)
  // ============================================================
  static const String prefToken = 'token';
  static const String prefUsuario = 'usuario';
  static const String prefTheme = 'theme_mode';
  static const String prefUserId = 'user_id';

  // ============================================================
  // 📝 TIPOS DE REPORTE
  // ============================================================
  static const List<String> tiposReporte = [
    'Robo',
    'Asalto',
    'Vandalismo',
    'Accidente',
    'Violencia',
    'Extorsión',
    'Emergencia médica',
    'Incidente de seguridad',
    'Situación sospechosa',
    'Ayuda humanitaria',
    'Otro',
  ];

  // ============================================================
  // 📊 ESTADOS DE REPORTE
  // ============================================================
  static const List<String> estadosReporte = [
    'pendiente',
    'en_proceso',
    'resuelto',
    'cerrado',
  ];

  // ============================================================
  // ⚠️ MENSAJES DE ERROR
  // ============================================================
  static const String errorConexion =
      'Error de conexión. Verifica tu internet.';
  static const String errorCredenciales =
      'Usuario o contraseña incorrectos.';
  static const String errorGenerico =
      'Ha ocurrido un error. Intenta nuevamente.';
  static const String errorServidor =
      'Error del servidor. Intenta más tarde.';
  static const String errorSinConexion =
      'Sin conexión al servidor. Verifica tu red WiFi.';

  // ============================================================
  // 🎨 TEXTOS DE LA APP
  // ============================================================
  static const String appName = 'WARDA';
  static const String appVersion = '1.0.0';
  static const String appSlogan = 'Reporta. Alerta. Protege.';

  // ============================================================
  // ⏱️ TIMEOUTS (en segundos)
  // ============================================================
  // Aumentado a 30s porque Render "duerme" el servicio gratis
  // y tarda ~20-30 segundos en despertar la primera vez.
  static const int httpTimeoutSeconds = 30;

  // ============================================================
  // 📱 MODO DE DESARROLLO
  // ============================================================
  static const bool debugMode = true;
}