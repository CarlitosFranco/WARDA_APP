// ============================================================
// 📁 services/auth_service.dart
// Servicio de autenticación usando SQLite
// ============================================================

import 'package:warda/models/usuario_model.dart';
import 'package:warda/services/database_service.dart';

class AuthService {
  final DatabaseService _db = DatabaseService();

  // ============================================================
  // 🆕 REGISTRO
  // ============================================================
  Future<Usuario> register(Usuario usuario, String password) async {
    // Verificar si el email ya existe
    final existe = await _db.usuarioExiste(usuario.email);
    if (existe) {
      throw Exception('El email ya está registrado');
    }

    // Insertar usuario en la BD
    await _db.insertUsuario(usuario, password);

    // Recuperar el usuario creado (con sus contactos)
    final nuevoUsuario = await _db.getUsuarioByEmail(usuario.email);
    if (nuevoUsuario == null) {
      throw Exception('Error al registrar usuario');
    }

    return nuevoUsuario;
  }

  // ============================================================
  // 🔐 LOGIN
  // ============================================================
  Future<Usuario> login(String email, String password) async {
    final usuario = await _db.login(email, password);
    if (usuario == null) {
      throw Exception('Email o contraseña incorrectos');
    }
    return usuario;
  }

  // ============================================================
  // 👤 OBTENER USUARIO
  // ============================================================
  Future<Usuario?> getUserByEmail(String email) async {
    return await _db.getUsuarioByEmail(email);
  }

  Future<Usuario?> getUserById(String id) async {
    return await _db.getUsuarioById(id);
  }

  // ============================================================
  // ✏️ ACTUALIZAR USUARIO
  // ============================================================
  Future<Usuario> actualizarUsuario(Usuario usuario) async {
    await _db.updateUsuario(usuario);

    // Recuperar el usuario actualizado
    final actualizado = await _db.getUsuarioById(usuario.id);
    if (actualizado == null) {
      throw Exception('Error al actualizar usuario');
    }
    return actualizado;
  }

  // ============================================================
  // 📞 CONTACTOS DE EMERGENCIA
  // ============================================================
  Future<Usuario> agregarContacto(
    String usuarioId,
    String nombre,
    String telefono,
    String relacion,
  ) async {
    // Crear nuevo contacto con ID único
    final nuevoContacto = ContactoEmergencia(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nombre: nombre.trim(),
      telefono: telefono.trim(),
      relacion: relacion.trim(),
    );

    // Insertar en la BD
    await _db.insertContacto(usuarioId, nuevoContacto);

    // Recuperar usuario actualizado
    final usuario = await _db.getUsuarioById(usuarioId);
    if (usuario == null) {
      throw Exception('Error al agregar contacto');
    }
    return usuario;
  }

  Future<void> eliminarContacto(String contactoId) async {
    await _db.deleteContacto(contactoId);
  }

  Future<List<ContactoEmergencia>> getContactos(String usuarioId) async {
    return await _db.getContactosByUsuario(usuarioId);
  }

  // ============================================================
  // 🚪 LOGOUT
  // ============================================================
  Future<void> logout() async {
    // Por ahora, no hay sesión persistente que limpiar.
    // En el futuro podríamos guardar el token o el último usuario
    // en SharedPreferences y limpiarlo aquí.
  }

  // ============================================================
  // 🧹 ELIMINAR TODOS LOS DATOS (para pruebas)
  // ============================================================
  Future<void> deleteAll() async {
    await _db.deleteAll();
  }
}