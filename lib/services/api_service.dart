import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:warda/models/reporte_model.dart';
import 'package:warda/models/usuario_model.dart';
import 'package:warda/utils/constants.dart';

class ApiService {
  final String baseUrl = AppConstants.apiUrl;
  String? _token;

  // ============================================================
  // 🔹 BASE DE DATOS LOCAL (SIMULADA)
  // ============================================================
  static final List<Usuario> _usuariosLocales = [];
  static final List<Reporte> _reportesLocales = [];

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

  // ============================================================
  // 👤 USUARIOS (MOCK)
  // ============================================================

  Future<Usuario> getUsuario(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final usuario = _usuariosLocales.firstWhere(
      (u) => u.id == id,
      orElse: () => Usuario(
        id: id,
        nombre: 'Usuario de Prueba',
        email: 'test@warda.com',
        telefono: '999999999',
        contactosEmergencia: [],
        notificacionesActivas: true,
        ubicacionCompartida: true,
      ),
    );

    return usuario;
  }

  Future<Usuario> actualizarUsuario(Usuario usuario) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _usuariosLocales.indexWhere((u) => u.id == usuario.id);
    if (index != -1) {
      _usuariosLocales[index] = usuario;
    } else {
      _usuariosLocales.add(usuario);
    }

    return usuario;
  }

  Future<Usuario> agregarContactoEmergencia(
    String usuarioId,
    String nombre,
    String telefono,
    String relacion,
  ) async {
    await Future.delayed(const Duration(milliseconds: 400));

    Usuario usuario;
    final existing = _usuariosLocales.firstWhere(
      (u) => u.id == usuarioId,
      orElse: () => Usuario(
        id: usuarioId,
        nombre: 'Usuario',
        email: 'usuario@warda.com',
        telefono: '999999999',
        contactosEmergencia: [],
        notificacionesActivas: true,
        ubicacionCompartida: true,
      ),
    );

    if (!_usuariosLocales.any((u) => u.id == usuarioId)) {
      _usuariosLocales.add(existing);
    }

    final nuevoContacto = ContactoEmergencia(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nombre: nombre.trim(),
      telefono: telefono.trim(),
      relacion: relacion.trim(),
    );

    final usuarioActualizado = existing.copyWith(
      contactosEmergencia: [...existing.contactosEmergencia, nuevoContacto],
    );

    final index = _usuariosLocales.indexWhere((u) => u.id == usuarioId);
    if (index != -1) {
      _usuariosLocales[index] = usuarioActualizado;
    } else {
      _usuariosLocales.add(usuarioActualizado);
    }

    return usuarioActualizado;
  }

  // ============================================================
  // 📋 REPORTES (MOCK)
  // ============================================================

  Future<List<Reporte>> getReportes(String usuarioId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (_reportesLocales.isEmpty) {
      _agregarReportesPrueba(usuarioId);
    }

    return _reportesLocales
        .where((r) => r.usuarioId == usuarioId)
        .toList();
  }

  Future<Reporte> crearReporte(Reporte reporte) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final nuevoReporte = Reporte(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titulo: reporte.titulo,
      descripcion: reporte.descripcion,
      tipo: reporte.tipo,
      estado: 'pendiente',
      fecha: DateTime.now(),
      ubicacion: reporte.ubicacion,
      latitud: reporte.latitud,
      longitud: reporte.longitud,
      imagenes: reporte.imagenes,
      usuarioId: reporte.usuarioId,
    );

    _reportesLocales.add(nuevoReporte);
    return nuevoReporte;
  }

  Future<Reporte> actualizarReporte(String id, Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _reportesLocales.indexWhere((r) => r.id == id);
    if (index == -1) {
      throw Exception('Reporte no encontrado');
    }

    final reporte = _reportesLocales[index];
    final actualizado = Reporte(
      id: reporte.id,
      titulo: data['titulo'] ?? reporte.titulo,
      descripcion: data['descripcion'] ?? reporte.descripcion,
      tipo: data['tipo'] ?? reporte.tipo,
      estado: data['estado'] ?? reporte.estado,
      fecha: reporte.fecha,
      ubicacion: data['ubicacion'] ?? reporte.ubicacion,
      latitud: data['latitud'] ?? reporte.latitud,
      longitud: data['longitud'] ?? reporte.longitud,
      imagenes: data['imagenes'] ?? reporte.imagenes,
      usuarioId: reporte.usuarioId,
    );

    _reportesLocales[index] = actualizado;
    return actualizado;
  }

  // ============================================================
  // 🗑️ ELIMINAR REPORTE (CORREGIDO)
  // ============================================================
  Future<bool> eliminarReporte(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));

    // Buscar el índice del reporte
    final index = _reportesLocales.indexWhere((r) => r.id == id);
    if (index != -1) {
      _reportesLocales.removeAt(index);
      return true; // ✅ Se eliminó correctamente
    }
    return false; // ❌ No se encontró el reporte
  }

  // ============================================================
  // 🧪 DATOS DE PRUEBA
  // ============================================================

  void _agregarReportesPrueba(String usuarioId) {
    if (_reportesLocales.isNotEmpty) return;

    final reportes = [
      Reporte(
        id: '1',
        titulo: 'Robo en tienda',
        descripcion: 'Dos sujetos armados robaron la tienda de la esquina',
        tipo: 'Robo',
        estado: 'pendiente',
        fecha: DateTime.now().subtract(const Duration(hours: 2)),
        ubicacion: 'Av. Principal 123',
        latitud: -12.0734,
        longitud: -77.1217,
        usuarioId: usuarioId,
      ),
      Reporte(
        id: '2',
        titulo: 'Accidente de tránsito',
        descripcion: 'Choque entre dos autos en el cruce',
        tipo: 'Accidente',
        estado: 'en_proceso',
        fecha: DateTime.now().subtract(const Duration(hours: 5)),
        ubicacion: 'Calle Los Pinos 456',
        latitud: -12.0800,
        longitud: -77.1150,
        usuarioId: usuarioId,
      ),
      Reporte(
        id: '3',
        titulo: 'Vandalismo en parque',
        descripcion: 'Destrucción de mobiliario urbano',
        tipo: 'Vandalismo',
        estado: 'resuelto',
        fecha: DateTime.now().subtract(const Duration(days: 1)),
        ubicacion: 'Parque Central',
        latitud: -12.0650,
        longitud: -77.1300,
        usuarioId: usuarioId,
      ),
    ];

    _reportesLocales.addAll(reportes);
  }

  // ============================================================
  // 🧹 LIMPIAR DATOS (para pruebas)
  // ============================================================

  void limpiarReportes() {
    _reportesLocales.clear();
  }

  void limpiarUsuarios() {
    _usuariosLocales.clear();
  }

  void limpiarTodo() {
    _reportesLocales.clear();
    _usuariosLocales.clear();
  }
}