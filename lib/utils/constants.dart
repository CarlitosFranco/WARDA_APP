// ============================================================
// 📁 utils/constants.dart
// Constantes globales de WARDA
// ============================================================

class AppConstants {
  // ============================================================
  // 🌐 API
  // ============================================================
  // Para DESARROLLO (backend local en tu PC):
  //   - Emulador Android: 'http://10.0.2.2:3000/api'
  //   - Celular físico:   'http://192.168.0.4:3000/api'  ← Tu IP local
  //   - Web (Chrome):     'http://localhost:3000/api'
  //
  // Para PRODUCCIÓN (cuando lo subas a un servidor):
  //   - 'https://api.warda.com/v1'
  //
  // ⚠️ IMPORTANTE: Si tu IP local cambia (por ejemplo al reiniciar el router),
  //    actualízala aquí. Puedes verla con `ipconfig` en PowerShell.
  // ============================================================
  static const String apiUrl = 'http://192.168.0.4:3000/api';

  // ============================================================
  // 💾 PREFERENCIAS (SharedPreferences)
  // ============================================================
  static const String prefToken = 'token';
  static const String prefUsuario = 'usuario';
  static const String prefTheme = 'theme_mode';
  static const String prefUserId = 'user_id'; // NUEVO: para persistir sesión

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
  static const int httpTimeoutSeconds = 15;

  // ============================================================
  // 📱 MODO DE DESARROLLO
  // ============================================================
  // Cambia a `true` cuando quieras ver logs más detallados
  static const bool debugMode = true;
}