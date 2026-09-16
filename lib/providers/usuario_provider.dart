// ============================================================
// 📁 providers/usuario_provider.dart
// Provider complementario para gestionar datos del usuario
// (trabaja en conjunto con AuthProvider y DatabaseService)
// ============================================================

import 'package:flutter/material.dart';
import 'package:warda/models/usuario_model.dart';
import 'package:warda/services/database_service.dart';

class UsuarioProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();

  Usuario? _usuario;
  bool _isLoading = false;
  String? _error;

  // ============================================================
  // GETTERS
  // ============================================================
  Usuario? get usuario => _usuario;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ContactoEmergencia> get contactos =>
      _usuario?.contactosEmergencia ?? const [];

  // ============================================================
  // 🔄 CARGAR USUARIO DESDE SQLITE
  // ============================================================
  Future<void> cargarUsuario(String id) async {
    _setLoading(true);
    _clearError();

    try {
      final usuario = await _db.getUsuarioById(id);
      _usuario = usuario; // Puede ser null si no existe
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
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
      await _db.updateUsuario(usuario);

      // Recargar el usuario actualizado
      final actualizado = await _db.getUsuarioById(usuario.id);
      _usuario = actualizado ?? usuario;

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
      // Crear nuevo contacto
      final nuevoContacto = ContactoEmergencia(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nombre: nombre.trim(),
        telefono: telefono.trim(),
        relacion: relacion.trim(),
      );

      // Guardar en SQLite
      await _db.insertContacto(usuarioId, nuevoContacto);

      // Recargar usuario (con contactos actualizados)
      _usuario = await _db.getUsuarioById(usuarioId);

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
  // ❌ ELIMINAR CONTACTO DE EMERGENCIA
  // ============================================================
  Future<bool> eliminarContactoEmergencia(String contactoId) async {
    _setLoading(true);
    _clearError();

    try {
      await _db.deleteContacto(contactoId);

      // Recargar usuario si tenemos su ID
      if (_usuario != null) {
        _usuario = await _db.getUsuarioById(_usuario!.id);
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

  // ============================================================
  // 📋 OBTENER LISTA DE CONTACTOS (helper)
  // ============================================================
  List<ContactoEmergencia> getContactos() {
    return _usuario?.contactosEmergencia ?? const [];
  }

  // ============================================================
  // 🔍 REFRESCAR USUARIO DESDE LA BD
  // ============================================================
  Future<void> refrescar() async {
    if (_usuario == null) return;

    try {
      final actualizado = await _db.getUsuarioById(_usuario!.id);
      if (actualizado != null) {
        _usuario = actualizado;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
    }
  }

  // ============================================================
  // 🧹 LIMPIAR USUARIO (para logout)
  // ============================================================
  void limpiarUsuario() {
    _usuario = null;
    _error = null;
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
    // No notificamos aquí para evitar doble rebuild
  }
}