// ============================================================
// 📁 services/auth_service.dart
// Servicio de autenticación - HTTP (backend) + SQLite (caché)
// ============================================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:warda/models/usuario_model.dart';
import 'package:warda/services/database_service.dart';
import 'package:warda/services/token_storage.dart';
import 'package:warda/utils/constants.dart';

class AuthService {
  final DatabaseService _db = DatabaseService();
  final String _baseUrl = AppConstants.apiUrl;

  // ============================================================
  // 📝 REGISTRO
  // ============================================================
  Future<Usuario> register(Usuario usuario, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'id': usuario.id,
              'nombre': usuario.nombre,
              'email': usuario.email,
              'telefono': usuario.telefono,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: AppConstants.httpTimeoutSeconds));

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        await TokenStorage.saveSession(
          token: data['data']['token'],
          userId: usuario.id,
        );

        final nuevoUsuario = Usuario.fromMap(data['data']['usuario']);

        try {
          await _db.insertUsuario(nuevoUsuario, password);
        } catch (_) {}

        return nuevoUsuario;
      } else {
        throw Exception(
          data['error']?['message'] ?? 'Error al registrar usuario',
        );
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException') ||
          e.toString().contains('Connection refused')) {
        final existe = await _db.usuarioExiste(usuario.email);
        if (existe) {
          throw Exception('El email ya está registrado');
        }

        await _db.insertUsuario(usuario, password);
        final nuevoUsuario = await _db.getUsuarioByEmail(usuario.email);
        if (nuevoUsuario == null) {
          throw Exception('Error al registrar usuario localmente');
        }

        await TokenStorage.saveSession(
          token: 'local_${usuario.id}',
          userId: usuario.id,
        );

        return nuevoUsuario;
      }
      rethrow;
    }
  }

  // ============================================================
  // 🔐 LOGIN
  // ============================================================
  Future<Usuario> login(String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: AppConstants.httpTimeoutSeconds));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final usuario = Usuario.fromMap(data['data']['usuario']);

        await TokenStorage.saveSession(
          token: data['data']['token'],
          userId: usuario.id,
        );

        try {
          await _db.insertUsuario(usuario, password);
        } catch (_) {}

        return usuario;
      } else {
        throw Exception(
          data['error']?['message'] ?? 'Email o contraseña incorrectos',
        );
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException') ||
          e.toString().contains('Connection refused')) {
        final usuarioLocal = await _db.login(email, password);
        if (usuarioLocal == null) {
          throw Exception('Sin conexión. Verifica tus credenciales locales.');
        }

        await TokenStorage.saveSession(
          token: 'local_${usuarioLocal.id}',
          userId: usuarioLocal.id,
        );

        return usuarioLocal;
      }
      rethrow;
    }
  }

  // ============================================================
  // 👤 OBTENER USUARIO ACTUAL (desde el backend)
  // ============================================================
  Future<Usuario?> getCurrentUser() async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null || token.startsWith('local_')) {
        final userId = await TokenStorage.getUserId();
        if (userId == null) return null;
        return await _db.getUsuarioById(userId);
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: AppConstants.httpTimeoutSeconds));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final usuario = Usuario.fromMap(data['data']['usuario']);

        try {
          await _db.updateUsuario(usuario);
        } catch (_) {}

        return usuario;
      } else if (response.statusCode == 401) {
        await TokenStorage.clearSession();
        return null;
      }
      return null;
    } catch (e) {
      final userId = await TokenStorage.getUserId();
      if (userId == null) return null;
      return await _db.getUsuarioById(userId);
    }
  }

  // ============================================================
  // 👤 OBTENER USUARIO POR ID (usado por AuthProvider)
  // ============================================================
  Future<Usuario?> getUserById(String id) async {
    try {
      final token = await TokenStorage.getToken();

      if (token != null && !token.startsWith('local_')) {
        final response = await http.get(
          Uri.parse('$_baseUrl/auth/me'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: AppConstants.httpTimeoutSeconds));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final usuario = Usuario.fromMap(data['data']['usuario']);

          try {
            await _db.updateUsuario(usuario);
          } catch (_) {}

          return usuario;
        }
      }
    } catch (_) {}

    return await _db.getUsuarioById(id);
  }

  // ============================================================
  // 📧 OBTENER USUARIO POR EMAIL
  // ============================================================
  Future<Usuario?> getUserByEmail(String email) async {
    return await _db.getUsuarioByEmail(email);
  }

  // ============================================================
  // ✏️ ACTUALIZAR USUARIO
  // ============================================================
  Future<Usuario> actualizarUsuario(Usuario usuario) async {
    await _db.updateUsuario(usuario);

    try {
      final token = await TokenStorage.getToken();
      if (token != null && !token.startsWith('local_')) {
        await http.put(
          Uri.parse('$_baseUrl/auth/me'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(usuario.toMap()),
        ).timeout(const Duration(seconds: AppConstants.httpTimeoutSeconds));
      }
    } catch (_) {}

    return usuario;
  }

  // ============================================================
  // 📞 CONTACTOS
  // ============================================================
  Future<Usuario> agregarContacto(
    String usuarioId,
    String nombre,
    String telefono,
    String relacion,
  ) async {
    final contacto = ContactoEmergencia(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nombre: nombre.trim(),
      telefono: telefono.trim(),
      relacion: relacion.trim(),
    );

    await _db.insertContacto(usuarioId, contacto);
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
    await TokenStorage.clearSession();
  }

  // ============================================================
  // 🧹 ELIMINAR TODOS LOS DATOS (para pruebas)
  // ============================================================
  Future<void> deleteAll() async {
    await _db.deleteAll();
    await TokenStorage.clearAll();
  }
}