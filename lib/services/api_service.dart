// ============================================================
// 📁 services/api_service.dart
// Servicio de Reportes usando SQLite
// ============================================================

import 'package:warda/models/reporte_model.dart';
import 'package:warda/services/database_service.dart';

class ApiService {
  final DatabaseService _db = DatabaseService();

  // ============================================================
  // 📋 OBTENER REPORTES
  // ============================================================

  /// Obtener todos los reportes de un usuario
  Future<List<Reporte>> getReportes(String usuarioId) async {
    return await _db.getReportesByUsuario(usuarioId);
  }

  /// Obtener todos los reportes (sin filtrar por usuario)
  Future<List<Reporte>> getAllReportes() async {
    return await _db.getAllReportes();
  }

  // ============================================================
  // ✏️ CREAR REPORTE
  // ============================================================

  Future<Reporte> crearReporte(Reporte reporte) async {
    // Asegurar que tenga ID único
    final nuevoReporte = Reporte(
      id: reporte.id.isEmpty
          ? DateTime.now().millisecondsSinceEpoch.toString()
          : reporte.id,
      titulo: reporte.titulo,
      descripcion: reporte.descripcion,
      tipo: reporte.tipo,
      estado: reporte.estado.isEmpty ? 'pendiente' : reporte.estado,
      fecha: reporte.fecha,
      ubicacion: reporte.ubicacion,
      latitud: reporte.latitud,
      longitud: reporte.longitud,
      imagenes: reporte.imagenes,
      usuarioId: reporte.usuarioId,
    );

    // Guardar en SQLite
    await _db.insertReporte(nuevoReporte);
    return nuevoReporte;
  }

  // ============================================================
  // 🔄 ACTUALIZAR REPORTE
  // ============================================================

  Future<Reporte> actualizarReporte(
    String id,
    Map<String, dynamic> data,
  ) async {
    // Obtener el reporte existente
    final reportes = await _db.getAllReportes();
    final index = reportes.indexWhere((r) => r.id == id);
    if (index == -1) {
      throw Exception('Reporte no encontrado');
    }

    // Aplicar cambios
    final original = reportes[index];
    final actualizado = original.copyWith(
      titulo: data['titulo'] as String?,
      descripcion: data['descripcion'] as String?,
      tipo: data['tipo'] as String?,
      estado: data['estado'] as String?,
      ubicacion: data['ubicacion'] as String?,
      latitud: data['latitud'] != null
          ? (data['latitud'] as num).toDouble()
          : null,
      longitud: data['longitud'] != null
          ? (data['longitud'] as num).toDouble()
          : null,
      imagenes: data['imagenes'] as List<String>?,
    );

    // Guardar cambios
    await _db.updateReporte(actualizado);
    return actualizado;
  }

  // ============================================================
  // 🗑️ ELIMINAR REPORTE
  // ============================================================

  Future<bool> eliminarReporte(String id) async {
    try {
      await _db.deleteReporte(id);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ============================================================
  // 🔍 OBTENER REPORTE POR ID
  // ============================================================

  Future<Reporte?> getReporteById(String id) async {
    final reportes = await _db.getAllReportes();
    try {
      return reportes.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }
}