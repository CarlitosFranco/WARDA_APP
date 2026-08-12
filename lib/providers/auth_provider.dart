import 'package:flutter/material.dart';
import 'package:warda/models/usuario_model.dart';
import 'package:warda/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  Usuario? _usuarioActual;
  bool _isLoading = false;
  String? _error;

  Usuario? get usuarioActual => _usuarioActual;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _usuarioActual != null;

  set usuarioActual(Usuario? usuario) {
    _usuarioActual = usuario;
    notifyListeners();
  }

  // ✅ REGISTRO CON SQLITE
  Future<bool> register(Usuario usuario, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final nuevoUsuario = await _authService.register(usuario, password);
      _usuarioActual = nuevoUsuario;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  // ✅ LOGIN CON SQLITE
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final usuario = await _authService.login(email, password);
      _usuarioActual = usuario;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  // ✅ LOGIN COMO INVITADO
  void loginComoInvitado() {
    _usuarioActual = Usuario(
      id: 'invitado_${DateTime.now().millisecondsSinceEpoch}',
      nombre: 'Invitado',
      email: 'invitado@warda.com',
      telefono: '000000000',
      notificacionesActivas: true,
      ubicacionCompartida: true,
    );
    notifyListeners();
  }

  // ✅ VERIFICAR ESTADO
  Future<void> checkAuthStatus() async {
    _setLoading(true);
    // Simulación: podrías verificar SharedPreferences aquí
    _setLoading(false);
  }

  // ✅ CERRAR SESIÓN
  Future<void> logout() async {
    _usuarioActual = null;
    notifyListeners();
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