// ============================================================
// 📁 services/token_storage.dart
// Almacenamiento local del token JWT y datos de sesión
// ============================================================

import 'package:shared_preferences/shared_preferences.dart';
import 'package:warda/utils/constants.dart';

class TokenStorage {
  // ============================================================
  // 💾 GUARDAR TOKEN Y USUARIO
  // ============================================================
  static Future<void> saveSession({
    required String token,
    required String userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefToken, token);
    await prefs.setString(AppConstants.prefUserId, userId);
  }

  // ============================================================
  // 🔑 OBTENER TOKEN
  // ============================================================
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.prefToken);
  }

  // ============================================================
  // 👤 OBTENER ID DEL USUARIO
  // ============================================================
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.prefUserId);
  }

  // ============================================================
  // ✔️ VERIFICAR SI HAY SESIÓN ACTIVA
  // ============================================================
  static Future<bool> hasSession() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ============================================================
  // 🧹 LIMPIAR SESIÓN (logout)
  // ============================================================
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.prefToken);
    await prefs.remove(AppConstants.prefUserId);
  }

  // ============================================================
  // 🗑️ LIMPIAR TODO (útil para debugging)
  // ============================================================
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}