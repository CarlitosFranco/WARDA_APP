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

  // Cargar reportes
  Future<void> cargarReportes(String usuarioId) async {
    _setLoading(true);
    try {
      _reportes = await _apiService.getReportes(usuarioId);
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  // Crear reporte
  Future<bool> crearReporte(Reporte reporte) async {
    _setLoading(true);
    try {
      final nuevo = await _apiService.crearReporte(reporte);
      _reportes.insert(0, nuevo);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Actualizar estado del reporte
  Future<bool> actualizarEstado(String reporteId, String nuevoEstado) async {
    _setLoading(true);
    try {
      final actualizado = await _apiService.actualizarReporte(reporteId, {
        'estado': nuevoEstado,
      });
      final index = _reportes.indexWhere((r) => r.id == reporteId);
      if (index != -1) {
        _reportes[index] = actualizado;
      }
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}