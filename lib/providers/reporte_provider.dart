// ============================================================
// 📁 providers/reporte_provider.dart
// Provider de reportes usando SQLite
// ============================================================

import 'package:flutter/material.dart';
import 'package:warda/models/reporte_model.dart';
import 'package:warda/services/api_service.dart';

class ReporteProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Reporte> _reportes = [];
  bool _isLoading = false;
  String? _error;

  List<Reporte> get reportes => _reportes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isEmpty => _reportes.isEmpty;
  int get total => _reportes.length;

  // ============================================================
  // 📋 CARGAR REPORTES DE UN USUARIO
  // ============================================================
  Future<void> cargarReportes(String usuarioId) async {
    _setLoading(true);
    _clearError();

    try {
      _reportes = await _apiService.getReportes(usuarioId);
      _setLoading(false);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _setLoading(false);
    }
  }

  // ============================================================
  // 🌍 CARGAR TODOS LOS REPORTES (para el mapa)
  // ============================================================
  Future<void> cargarTodosReportes() async {
    _setLoading(true);
    _clearError();

    try {
      _reportes = await _apiService.getAllReportes();
      _setLoading(false);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _setLoading(false);
    }
  }

  // ============================================================
  // ✏️ CREAR REPORTE
  // ============================================================
  Future<bool> crearReporte(Reporte reporte) async {
    _setLoading(true);
    _clearError();

    try {
      final nuevo = await _apiService.crearReporte(reporte);
      // Insertar al inicio para que aparezca primero
      _reportes.insert(0, nuevo);
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
  // 🔄 ACTUALIZAR ESTADO DEL REPORTE
  // ============================================================
  Future<bool> actualizarEstado(String reporteId, String nuevoEstado) async {
    _setLoading(true);
    _clearError();

    try {
      final actualizado = await _apiService.actualizarReporte(reporteId, {
        'estado': nuevoEstado,
      });

      final index = _reportes.indexWhere((r) => r.id == reporteId);
      if (index != -1) {
        _reportes[index] = actualizado;
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
  // 🗑️ ELIMINAR REPORTE
  // ============================================================
  Future<bool> eliminarReporte(String reporteId) async {
    _setLoading(true);
    _clearError();

    try {
      final exito = await _apiService.eliminarReporte(reporteId);

      if (exito) {
        _reportes.removeWhere((r) => r.id == reporteId);
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _error = 'No se pudo eliminar el reporte';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  // ============================================================
  // 🔍 OBTENER REPORTE POR ID
  // ============================================================
  Reporte? getReporteById(String id) {
    try {
      return _reportes.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // 🔎 FILTRAR REPORTES POR TIPO
  // ============================================================
  List<Reporte> filtrarPorTipo(String tipo) {
    if (tipo.isEmpty) return _reportes;
    return _reportes.where((r) => r.tipo == tipo).toList();
  }

  // ============================================================
  // 🧹 LIMPIAR REPORTES (para logout)
  // ============================================================
  void limpiarReportes() {
    _reportes.clear();
    _error = null;
    notifyListeners();
  }

  // ============================================================
  // 🛠️ HELPERS INTERNOS
  // ============================================================
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    // No llamamos a notifyListeners aquí para evitar doble rebuild
  }
}