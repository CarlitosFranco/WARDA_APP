// ============================================================
// 📁 main.dart
// Punto de entrada de WARDA
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warda/providers/auth_provider.dart';
import 'package:warda/providers/reporte_provider.dart';
import 'package:warda/routes/app_routes.dart';
import 'package:warda/services/database_service.dart';

// ============================================================
// 🚀 MAIN: Inicializar binding y BD, luego correr la app
// ============================================================
Future<void> main() async {
  // Necesario para usar plugins antes de runApp()
  WidgetsFlutterBinding.ensureInitialized();

  // Pre-inicializar la base de datos SQLite
  // (crea las tablas si no existen)
  try {
    await DatabaseService().database;
    debugPrint('✅ Base de datos WARDA lista');
  } catch (e) {
    debugPrint('❌ Error al inicializar la base de datos: $e');
  }

  runApp(const MyApp());
}

// ============================================================
// 🎨 MY APP: Configuración de providers y tema
// ============================================================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ReporteProvider()),
        // ❌ UsuarioProvider eliminado (reemplazado por AuthProvider)
      ],
      child: MaterialApp(
        title: 'WARDA',
        debugShowCheckedModeBanner: false,

        // Rutas
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.routes,
        onGenerateRoute: AppRoutes.onGenerateRoute,

        // Tema de WARDA
        theme: _buildWardaTheme(),
      ),
    );
  }

  // ============================================================
  // 🎨 TEMA PERSONALIZADO DE WARDA
  // ============================================================
  ThemeData _buildWardaTheme() {
    // Colores de la marca WARDA
    const primaryColor = Color(0xFF6C63FF); // Morado principal
    const accentColor = Color(0xFFEF4444);  // Rojo (alertas)

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,

      // AppBar
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 2,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Botones elevados
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),

      // Inputs (textfields)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentColor, width: 2),
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // SnackBars
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}