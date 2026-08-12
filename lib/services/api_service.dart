import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:warda/models/reporte_model.dart';
import 'package:warda/models/usuario_model.dart';
import 'package:warda/utils/constants.dart';

class ApiService {
  final String baseUrl = AppConstants.apiUrl;
  String? _token;

  void setToken(String token) {
    _token = token;
  }

  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }

  // USUARIOS
  Future<Usuario> getUsuario(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/usuarios/$id'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return Usuario.fromMap(json.decode(response.body));
    } else {
      throw Exception('Error al cargar usuario: ${response.statusCode}');
    }
  }

  Future<Usuario> actualizarUsuario(Usuario usuario) async {
    final response = await http.put(
      Uri.parse('$baseUrl/usuarios/${usuario.id}'),
      headers: _getHeaders(),
      body: json.encode(usuario.toMap()),
    );

    if (response.statusCode == 200) {
      return Usuario.fromMap(json.decode(response.body));
    } else {
      throw Exception('Error al actualizar usuario: ${response.statusCode}');
    }
  }

  Future<Usuario> agregarContactoEmergencia(
    String usuarioId,
    String nombre,
    String telefono,
    String relacion,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/usuarios/$usuarioId/contactos'),
      headers: _getHeaders(),
      body: json.encode({
        'nombre': nombre,
        'telefono': telefono,
        'relacion': relacion,
      }),
    );

    if (response.statusCode == 200) {
      return Usuario.fromMap(json.decode(response.body));
    } else {
      throw Exception('Error al agregar contacto: ${response.statusCode}');
    }
  }

  // REPORTES
  Future<List<Reporte>> getReportes(String usuarioId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/reportes?usuarioId=$usuarioId'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => Reporte.fromMap(item)).toList();
    } else {
      throw Exception('Error al cargar reportes: ${response.statusCode}');
    }
  }

  Future<Reporte> crearReporte(Reporte reporte) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reportes'),
      headers: _getHeaders(),
      body: json.encode(reporte.toMap()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Reporte.fromMap(json.decode(response.body));
    } else {
      throw Exception('Error al crear reporte: ${response.statusCode}');
    }
  }

  Future<Reporte> actualizarReporte(String id, Map<String, dynamic> data) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/reportes/$id'),
      headers: _getHeaders(),
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      return Reporte.fromMap(json.decode(response.body));
    } else {
      throw Exception('Error al actualizar reporte: ${response.statusCode}');
    }
  }
}