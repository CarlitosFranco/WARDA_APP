class AppConstants {
  // API
  static const String apiUrl = 'https://api.warda.com/v1';
  // En desarrollo usar: 'http://localhost:3000/api'
  
  // Preferencias
  static const String prefToken = 'token';
  static const String prefUsuario = 'usuario';
  static const String prefTheme = 'theme_mode';
  
  // Tipos de reporte
  static const List<String> tiposReporte = [
    'Emergencia médica',
    'Incidente de seguridad',
    'Situación sospechosa',
    'Ayuda humanitaria',
    'Otro',
  ];
  
  // Estados de reporte
  static const List<String> estadosReporte = [
    'pendiente',
    'en proceso',
    'resuelto',
    'cerrado',
  ];
  
  // Mensajes de error
  static const String errorConexion = 'Error de conexión. Verifica tu internet.';
  static const String errorCredenciales = 'Usuario o contraseña incorrectos.';
  static const String errorGenerico = 'Ha ocurrido un error. Intenta nuevamente.';
  
  // Textos de la app
  static const String appName = 'WARDA';
  static const String appVersion = '1.0.0';
}