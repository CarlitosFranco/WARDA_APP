// ============================================================
// 📁 main.dart
// Punto de entrada de WARDA
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warda/providers/auth_provider.dart';
import 'package:warda/providers/reporte_provider.dart';
import 'package:warda/providers/theme_provider.dart';
import 'package:warda/routes/app_routes.dart';
import 'package:warda/services/database_service.dart';
import 'package:warda/utils/app_theme.dart';

// ============================================================
// 🚀 MAIN: Inicializar binding, BD y correr la app
// ============================================================
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await DatabaseService().database;
    debugPrint('✅ Base de datos WARDA lista');
  } catch (e) {
    debugPrint('❌ Error al inicializar la base de datos: $e');
  }

  runApp(const MyApp());
}

// ============================================================
// 🎨 MY APP: Providers + Tema dinámico
// ============================================================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ReporteProvider()),
        // ThemeProvider carga el tema guardado al iniciar
        ChangeNotifierProvider(
          create: (_) => ThemeProvider()..cargarTema(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'WARDA',
            debugShowCheckedModeBanner: false,

            // Rutas
            initialRoute: AppRoutes.splash,
            routes: AppRoutes.routes,
            onGenerateRoute: AppRoutes.onGenerateRoute,

            // Temas claro y oscuro
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
          );
        },
      ),
    );
  }
}