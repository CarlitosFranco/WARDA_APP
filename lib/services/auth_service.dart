import 'package:warda/models/usuario_model.dart';
import 'package:warda/services/database_service.dart';

class AuthService {
  final DatabaseService _db = DatabaseService();

  // ✅ REGISTRO CON SQLITE
  Future<Usuario> register(Usuario usuario, String password) async {
    final existe = await _db.usuarioExiste(usuario.email);
    if (existe) {
      throw Exception('El email ya está registrado');
    }

    await _db.insertUsuario(usuario, password);
    
    final nuevoUsuario = await _db.getUsuarioByEmail(usuario.email);
    if (nuevoUsuario == null) {
      throw Exception('Error al registrar usuario');
    }
    
    return nuevoUsuario;
  }

  // ✅ LOGIN CON SQLITE
  Future<Usuario> login(String email, String password) async {
    final usuario = await _db.login(email, password);
    if (usuario == null) {
      throw Exception('Email o contraseña incorrectos');
    }
    return usuario;
  }

  // ✅ OBTENER USUARIO POR EMAIL
  Future<Usuario?> getUserByEmail(String email) async {
    return await _db.getUsuarioByEmail(email);
  }

  // ✅ ELIMINAR TODOS LOS DATOS (para pruebas)
  Future<void> deleteAll() async {
    await _db.deleteAll();
  }
}