// ============================================================
// 📁 services/api_service.dart
// Servicio de reportes - HTTP (backend) + SQLite (caché)
// ============================================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:warda/models/reporte_model.dart';
import 'package:warda/services/database_service.dart';
import 'package:warda/services/token_storage.dart';
import 'package:warda/utils/constants.dart';

class ApiService {
  final DatabaseService _db = DatabaseService();
  final String _baseUrl = AppConstants.apiUrl;

  // ============================================================
  // 🛠️ HELPERS
  // ============================================================

  /// Construye los headers con el token JWT
  Future<Map<String, String>> _getHeaders() async {
    final token = await TokenStorage.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && !token.startsWith('local_'))
        'Authorization': 'Bearer $token',
    };
  }

  /// Verifica si el error es de conexión
  bool _esErrorDeRed(dynamic e) {
    final str = e.toString();
    return str.contains('SocketException') ||
        str.contains('TimeoutException') ||
        str.contains('Connection refused') ||
        str.contains('Failed host lookup');
  }

  // ============================================================
  // 📋 OBTENER TODOS LOS REPORTES (para el mapa)
  // ============================================================
  Future<List<Reporte>> getAllReportes() async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(Uri.parse('$_baseUrl/reportes'), headers: headers)
          .timeout(const Duration(seconds: AppConstants.httpTimeoutSeconds));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> lista = data['data']['reportes'] ?? [];
        final reportes = lista
            .map((item) => Reporte.fromMap(item as Map<String, dynamic>))
            .toList();

        // Actualizar caché local con los reportes del backend
        for (final r in reportes) {
          try {
            await _db.insertReporte(r);
          } catch (_) {}
        }

        return reportes;
      } else {
        throw Exception('Error al obtener reportes: ${response.statusCode}');
      }
    } catch (e) {
      if (_esErrorDeRed(e)) {
        // Fallback: leer de SQLite
        return await _db.getAllReportes();
      }
      rethrow;
    }
  }

  // ============================================================
  // 👤 OBTENER REPORTES DE UN USUARIO
  // ============================================================
  Future<List<Reporte>> getReportes(String usuarioId) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse('$_baseUrl/reportes/usuario/$usuarioId'),
            headers: headers,
          )
          .timeout(const Duration(seconds: AppConstants.httpTimeoutSeconds));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> lista = data['data']['reportes'] ?? [];
        final reportes = lista
            .map((item) => Reporte.fromMap(item as Map<String, dynamic>))
            .toList();

        // Cachear localmente
        for (final r in reportes) {
          try {
            await _db.insertReporte(r);
          } catch (_) {}
        }

        return reportes;
      } else {
        throw Exception(
          'Error al obtener reportes: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (_esErrorDeRed(e)) {
        return await _db.getReportesByUsuario(usuarioId);
      }
      rethrow;
    }
  }

  // ============================================================
  // 🔍 OBTENER REPORTE POR ID
  // ============================================================
  Future<Reporte?> getReporteById(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(Uri.parse('$_baseUrl/reportes/$id'), headers: headers)
          .timeout(const Duration(seconds: AppConstants.httpTimeoutSeconds));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reporte = Reporte.fromMap(data['data']['reporte']);
        try {
          await _db.insertReporte(reporte);
        } catch (_) {}
        return reporte;
      }
      return null;
    } catch (e) {
      if (_esErrorDeRed(e)) {
        final reportes = await _db.getAllReportes();
        try {
          return reportes.firstWhere((r) => r.id == id);
        } catch (_) {
          return null;
        }
      }
      rethrow;
    }
  }

  // ============================================================
  // ✏️ CREAR REPORTE
  // ============================================================
  Future<Reporte> crearReporte(Reporte reporte) async {
    // Asegurar ID único
    final nuevoReporte = reporte.id.isEmpty
        ? reporte.copyWith(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
          )
        : reporte;

    try {
      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse('$_baseUrl/reportes'),
            headers: headers,
            body: jsonEncode({
              'id': nuevoReporte.id,
              'titulo': nuevoReporte.titulo,
              'descripcion': nuevoReporte.descripcion,
              'tipo': nuevoReporte.tipo,
              'estado': nuevoReporte.estado,
              'ubicacion': nuevoReporte.ubicacion,
              'latitud': nuevoReporte.latitud,
              'longitud': nuevoReporte.longitud,
              'imagenes': nuevoReporte.imagenes,
            }),
          )
          .timeout(const Duration(seconds: AppConstants.httpTimeoutSeconds));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final creado = Reporte.fromMap(data['data']['reporte']);

        // Guardar en caché local
        try {
          await _db.insertReporte(creado);
        } catch (_) {}

        return creado;
      } else {
        final data = jsonDecode(response.body);
        throw Exception(
          data['error']?['message'] ?? 'Error al crear reporte',
        );
      }
    } catch (e) {
      if (_esErrorDeRed(e)) {
        // Guardar solo en SQLite
        await _db.insertReporte(nuevoReporte);
        return nuevoReporte;
      }
      rethrow;
    }
  }

  // ============================================================
  // 🔄 ACTUALIZAR REPORTE
  // ============================================================
  Future<Reporte> actualizarReporte(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .put(
            Uri.parse('$_baseUrl/reportes/$id'),
            headers: headers,
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: AppConstants.httpTimeoutSeconds));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final actualizado = Reporte.fromMap(responseData['data']['reporte']);

        try {
          await _db.updateReporte(actualizado);
        } catch (_) {}

        return actualizado;
      } else {
        final responseData = jsonDecode(response.body);
        throw Exception(
          responseData['error']?['message'] ?? 'Error al actualizar',
        );
      }
    } catch (e) {
      if (_esErrorDeRed(e)) {
        // Actualizar solo en SQLite
        final reportes = await _db.getAllReportes();
        final index = reportes.indexWhere((r) => r.id == id);
        if (index == -1) throw Exception('Reporte no encontrado');

        final original = reportes[index];
        final actualizado = original.copyWith(
          titulo: data['titulo'] as String?,
          descripcion: data['descripcion'] as String?,
          tipo: data['tipo'] as String?,
          estado: data['estado'] as String?,
        );
        await _db.updateReporte(actualizado);
        return actualizado;
      }
      rethrow;
    }
  }

  // ============================================================
  // 🗑️ ELIMINAR REPORTE
  // ============================================================
  Future<bool> eliminarReporte(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .delete(Uri.parse('$_baseUrl/reportes/$id'), headers: headers)
          .timeout(const Duration(seconds: AppConstants.httpTimeoutSeconds));

      if (response.statusCode == 200) {
        try {
          await _db.deleteReporte(id);
        } catch (_) {}
        return true;
      } else if (response.statusCode == 404) {
        return false;
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['error']?['message'] ?? 'Error al eliminar');
      }
    } catch (e) {
      if (_esErrorDeRed(e)) {
        try {
          await _db.deleteReporte(id);
          return true;
        } catch (_) {
          return false;
        }
      }
      rethrow;
    }
  }
}