// ============================================================
// 📁 providers/usuario_provider.dart
// Provider para gestionar el usuario y sus contactos de emergencia
// ============================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warda/models/usuario_model.dart';

class UsuarioProvider extends ChangeNotifier {
  Usuario? _usuario;
  bool _isLoading = false;
  String? _error;

  Usuario? get usuario => _usuario;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ContactoEmergencia> get contactos => _usuario?.contactosEmergencia ?? [];

  // ============================================================
  // 🔄 CARGAR USUARIO DESDE SHARED_PREFERENCES (funciona en Web)
  // ============================================================
  Future<void> cargarUsuario(String id) async {
    _setLoading(true);
    _clearError();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('usuario_$id');

      if (userJson != null) {
        // Si existe en SharedPreferences, lo recuperamos
        final Map<String, dynamic> map = Map<String, dynamic>.from(
          userJson as Map, // Asumimos que guardamos como JSON string
        );
        _usuario = Usuario.fromMap(map);
      } else {
        // Si no existe, creamos uno de prueba (o podrías cargar desde AuthProvider)
        _usuario = Usuario(
          id: id,
          nombre: 'Usuario de Prueba',
          email: 'test@warda.com',
          telefono: '999999999',
          contactosEmergencia: [],
          notificacionesActivas: true,
          ubicacionCompartida: true,
        );
        // Guardamos el usuario inicial
        await _guardarUsuario();
      }
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  // ============================================================
  // 💾 GUARDAR USUARIO EN SHARED_PREFERENCES
  // ============================================================
  Future<void> _guardarUsuario() async {
    if (_usuario == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final userMap = _usuario!.toMap();
      // Convertir a String JSON (podrías usar jsonEncode)
      await prefs.setString('usuario_${_usuario!.id}', userMap.toString());
    } catch (e) {
      // Si falla, solo lo registramos
      debugPrint('Error guardando usuario: $e');
    }
  }

  // ============================================================
  // ✏️ ACTUALIZAR DATOS DEL USUARIO
  // ============================================================
  Future<bool> actualizarUsuario(Usuario usuario) async {
    _setLoading(true);
    _clearError();

    try {
      _usuario = usuario;
      await _guardarUsuario();
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // ============================================================
  // ➕ AGREGAR CONTACTO DE EMERGENCIA
  // ============================================================
  Future<bool> agregarContactoEmergencia(
    String usuarioId,
    String nombre,
    String telefono,
    String relacion,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      // 1. Crear el nuevo contacto
      final nuevoContacto = ContactoEmergencia(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nombre: nombre.trim(),
        telefono: telefono.trim(),
        relacion: relacion.trim(),
      );

      // 2. Si no hay usuario, lo creamos temporal (por seguridad)
      if (_usuario == null) {
        _usuario = Usuario(
          id: usuarioId,
          nombre: 'Usuario',
          email: 'usuario@warda.com',
          telefono: '999999999',
          contactosEmergencia: [],
          notificacionesActivas: true,
          ubicacionCompartida: true,
        );
      }

      // 3. Agregar el contacto a la lista
      _usuario!.contactosEmergencia.add(nuevoContacto);

      // 4. Persistir en SharedPreferences
      await _guardarUsuario();

      // 5. Notificar cambios
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // ============================================================
  // ❌ ELIMINAR CONTACTO DE EMERGENCIA
  // ============================================================
  Future<bool> eliminarContactoEmergencia(String contactoId) async {
    _setLoading(true);
    _clearError();

    try {
      if (_usuario != null) {
        _usuario!.contactosEmergencia
            .removeWhere((contacto) => contacto.id == contactoId);
        await _guardarUsuario();
        notifyListeners();
      }
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // ============================================================
  // 📋 OBTENER LISTA DE CONTACTOS (método auxiliar)
  // ============================================================
  List<ContactoEmergencia> getContactos() {
    return _usuario?.contactosEmergencia ?? [];
  }

  // ============================================================
  // 🧹 LIMPIAR USUARIO (para logout)
  // ============================================================
  void limpiarUsuario() {
    _usuario = null;
    notifyListeners();
  }

  // ============================================================
  // 🛠️ MÉTODOS INTERNOS
  // ============================================================
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}