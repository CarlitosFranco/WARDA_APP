// ============================================================
// 📁 models/reporte_model.dart
// Modelo de Reporte/Incidente para WARDA
// Compatible con SQLite
// ============================================================

class Reporte {
  final String id;
  final String titulo;
  final String descripcion;
  final String tipo;
  final String estado;
  final DateTime fecha;
  final String? ubicacion;
  final double? latitud;
  final double? longitud;
  final List<String>? imagenes;
  final String usuarioId;

  Reporte({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.tipo,
    required this.estado,
    required this.fecha,
    this.ubicacion,
    this.latitud,
    this.longitud,
    this.imagenes,
    required this.usuarioId,
  });

  /// Convierte a Map para guardar en SQLite (tabla `reportes`).
  /// ⚠️ Las imágenes se guardan como un String separado por `|`.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'tipo': tipo,
      'estado': estado,
      'fecha': fecha.toIso8601String(),
      'ubicacion': ubicacion,
      'latitud': latitud,
      'longitud': longitud,
      'imagenes': (imagenes != null && imagenes!.isNotEmpty)
          ? imagenes!.join('|')
          : null,
      'usuarioId': usuarioId,
    };
  }

  /// Crea una instancia desde un Map (SQLite o JSON).
  /// Maneja `imagenes` como String (SQLite) o List (JSON/API).
  factory Reporte.fromMap(Map<String, dynamic> map) {
    return Reporte(
      id: (map['id'] ?? '').toString(),
      titulo: (map['titulo'] ?? '').toString(),
      descripcion: (map['descripcion'] ?? '').toString(),
      tipo: (map['tipo'] ?? '').toString(),
      estado: (map['estado'] ?? 'pendiente').toString(),
      fecha: _parseFecha(map['fecha']),
      ubicacion: map['ubicacion'] as String?,
      latitud: _parseDouble(map['latitud']),
      longitud: _parseDouble(map['longitud']),
      imagenes: _parseImagenes(map['imagenes']),
      usuarioId: (map['usuarioId'] ?? '').toString(),
    );
  }

  /// Crea una copia con datos actualizados
  Reporte copyWith({
    String? id,
    String? titulo,
    String? descripcion,
    String? tipo,
    String? estado,
    DateTime? fecha,
    String? ubicacion,
    double? latitud,
    double? longitud,
    List<String>? imagenes,
    String? usuarioId,
  }) {
    return Reporte(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      tipo: tipo ?? this.tipo,
      estado: estado ?? this.estado,
      fecha: fecha ?? this.fecha,
      ubicacion: ubicacion ?? this.ubicacion,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      imagenes: imagenes ?? this.imagenes,
      usuarioId: usuarioId ?? this.usuarioId,
    );
  }

  @override
  String toString() {
    return 'Reporte(id: $id, titulo: $titulo, tipo: $tipo, estado: $estado, usuarioId: $usuarioId)';
  }
}

// ============================================================
// 🛠️ HELPERS INTERNOS
// ============================================================

/// Convierte un valor (String, DateTime, null) a DateTime de forma segura.
DateTime _parseFecha(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is DateTime) return value;
  try {
    return DateTime.parse(value.toString());
  } catch (_) {
    return DateTime.now();
  }
}

/// Convierte un valor (int, double, String, null) a double de forma segura.
double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

/// Convierte `imagenes` en lista.
/// - Si viene como String (SQLite): separa por `|`.
/// - Si viene como List (JSON/API): la convierte directamente.
List<String>? _parseImagenes(dynamic value) {
  if (value == null) return null;

  // Si ya es una lista (viene de JSON/API)
  if (value is List) {
    final list = value.map((e) => e.toString()).toList();
    return list.isEmpty ? null : list;
  }

  // Si es un String (viene de SQLite)
  if (value is String) {
    if (value.isEmpty) return null;
    final list = value.split('|');
    return list.isEmpty ? null : list;
  }

  return null;
}