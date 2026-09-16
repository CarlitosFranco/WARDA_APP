// ============================================================
// 📁 providers/auth_provider.dart
// Provider de autenticación usando SQLite + SharedPreferences
// ============================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warda/models/usuario_model.dart';
import 'package:warda/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  // Clave para guardar el ID del usuario en SharedPreferences
  static const String _keyUserId = 'warda_user_id';

  Usuario? _usuarioActual;
  bool _isLoading = false;
  String? _error;

  Usuario? get usuarioActual => _usuarioActual;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _usuarioActual != null;

  // ============================================================
  // 📝 REGISTRO
  // ============================================================
  Future<bool> register(Usuario usuario, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final nuevoUsuario = await _authService.register(usuario, password);
      _usuarioActual = nuevoUsuario;

      // Guardar sesión (excepto si es invitado)
      await _guardarSesion(nuevoUsuario.id);

      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  // ============================================================
  // 🔐 LOGIN
  // ============================================================
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final usuario = await _authService.login(email, password);
      _usuarioActual = usuario;

      // Guardar sesión
      await _guardarSesion(usuario.id);

      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  // ============================================================
  // 🎭 LOGIN COMO INVITADO
  // ============================================================
  void loginComoInvitado() {
    _usuarioActual = Usuario(
      id: 'invitado_${DateTime.now().millisecondsSinceEpoch}',
      nombre: 'Invitado',
      email: 'invitado@warda.com',
      telefono: '000000000',
      notificacionesActivas: true,
      ubicacionCompartida: true,
    );
    _error = null;
    notifyListeners();
  }

  // ============================================================
  // 🔄 VERIFICAR ESTADO AL INICIAR LA APP
  // ============================================================
  Future<void> checkAuthStatus() async {
    _setLoading(true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(_keyUserId);

      if (userId != null && !userId.startsWith('invitado_')) {
        // Cargar usuario desde la BD
        final usuario = await _authService.getUserById(userId);
        if (usuario != null) {
          _usuarioActual = usuario;
        } else {
          // Si el usuario no existe en la BD, limpiar sesión
          await prefs.remove(_keyUserId);
        }
      }
    } catch (e) {
      _error = e.toString();
    }

    _setLoading(false);
  }

  // ============================================================
  // ✏️ ACTUALIZAR DATOS DEL USUARIO
  // ============================================================
  Future<bool> actualizarUsuario(Usuario usuario) async {
    _setLoading(true);
    _clearError();

    try {
      final actualizado = await _authService.actualizarUsuario(usuario);
      _usuarioActual = actualizado;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  // ============================================================
  // 📞 CONTACTOS DE EMERGENCIA
  // ============================================================
  Future<bool> agregarContacto(
    String nombre,
    String telefono,
    String relacion,
  ) async {
    if (_usuarioActual == null) {
      _error = 'Debes iniciar sesión para agregar contactos';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final usuarioActualizado = await _authService.agregarContacto(
        _usuarioActual!.id,
        nombre,
        telefono,
        relacion,
      );
      _usuarioActual = usuarioActualizado;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> eliminarContacto(String contactoId) async {
    if (_usuarioActual == null) return false;

    _setLoading(true);
    _clearError();

    try {
      await _authService.eliminarContacto(contactoId);

      // Recargar usuario para actualizar la lista de contactos
      final actualizado = await _authService.getUserById(_usuarioActual!.id);
      if (actualizado != null) {
        _usuarioActual = actualizado;
      }

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  List<ContactoEmergencia> getContactos() {
    return _usuarioActual?.contactosEmergencia ?? [];
  }

  // ============================================================
  // 🚪 CERRAR SESIÓN
  // ============================================================
  Future<void> logout() async {
    // Limpiar sesión persistida
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);

    // Llamar al servicio (placeholder por si se necesita más lógica)
    await _authService.logout();

    // Limpiar estado en memoria
    _usuarioActual = null;
    _error = null;
    notifyListeners();
  }

  // ============================================================
  // 🛠️ HELPERS INTERNOS
  // ============================================================
  Future<void> _guardarSesion(String userId) async {
    // No guardar sesión si es invitado
    if (userId.startsWith('invitado_')) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, userId);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}