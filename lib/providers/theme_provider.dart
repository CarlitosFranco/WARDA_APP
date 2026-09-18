// ============================================================
// 📁 providers/theme_provider.dart
// Maneja el modo claro/oscuro con persistencia
// ============================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warda/utils/constants.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // ============================================================
  // 📖 CARGAR TEMA GUARDADO AL INICIAR LA APP
  // ============================================================
  Future<void> cargarTema() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(AppConstants.prefTheme);

      if (saved == 'dark') {
        _themeMode = ThemeMode.dark;
      } else if (saved == 'light') {
        _themeMode = ThemeMode.light;
      } else {
        _themeMode = ThemeMode.system; // Sigue el sistema
      }

      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error al cargar tema: $e');
    }
  }

  // ============================================================
  // 🌙 CAMBIAR A MODO OSCURO
  // ============================================================
  Future<void> setDarkMode() async {
    _themeMode = ThemeMode.dark;
    notifyListeners();
    await _guardarTema('dark');
  }

  // ============================================================
  // ☀️ CAMBIAR A MODO CLARO
  // ============================================================
  Future<void> setLightMode() async {
    _themeMode = ThemeMode.light;
    notifyListeners();
    await _guardarTema('light');
  }

  // ============================================================
  // 🔄 SEGUIR EL SISTEMA
  // ============================================================
  Future<void> setSystemMode() async {
    _themeMode = ThemeMode.system;
    notifyListeners();
    await _guardarTema('system');
  }

  // ============================================================
  // 🔀 TOGGLE RÁPIDO (para el Switch del perfil)
  // ============================================================
  Future<void> toggleTheme(bool isDark) async {
    if (isDark) {
      await setDarkMode();
    } else {
      await setLightMode();
    }
  }

  // ============================================================
  // 💾 GUARDAR TEMA EN PREFERENCIAS
  // ============================================================
  Future<void> _guardarTema(String mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.prefTheme, mode);
    } catch (e) {
      debugPrint('❌ Error al guardar tema: $e');
    }
  }
}