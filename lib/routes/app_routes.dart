import 'package:flutter/material.dart';
import 'package:warda/screens/splash/splash_screen.dart';
import 'package:warda/screens/auth/login_screen.dart';
import 'package:warda/screens/auth/register_screen.dart';
import 'package:warda/screens/home/home_screen.dart';
import 'package:warda/screens/contactos/contactos_screen.dart';
import 'package:warda/screens/detalle/detalle_screen.dart';
import 'package:warda/screens/mapa/mapa_screen.dart'; // ✅ NUEVA IMPORTACIÓN
import 'package:warda/screens/reportes/reportes_screen.dart';
import 'package:warda/screens/reportes/crear_reporte_screen.dart';
import 'package:warda/screens/sos/sos_screen.dart';
import 'package:warda/screens/perfil/perfil_screen.dart';
import 'package:warda/screens/notificaciones/notificaciones_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String contactos = '/contactos';
  static const String detalle = '/detalle';
  static const String mapa = '/mapa'; // ✅ NUEVA RUTA
  static const String reportes = '/reportes';
  static const String crearReporte = '/crear-reporte';
  static const String sos = '/sos';
  static const String perfil = '/perfil';
  static const String notificaciones = '/notificaciones';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    home: (context) => const HomeScreen(),
    contactos: (context) => const ContactosScreen(),
    detalle: (context) => const DetalleScreen(),
    mapa: (context) => const MapaScreen(), // ✅ NUEVA RUTA
    reportes: (context) => const ReportesScreen(),
    crearReporte: (context) => const CrearReporteScreen(),
    sos: (context) => const SosScreen(),
    perfil: (context) => const PerfilScreen(),
    notificaciones: (context) => const NotificacionesScreen(),
  };

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case detalle:
        return MaterialPageRoute(
          builder: (context) => const DetalleScreen(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        );
    }
  }
}