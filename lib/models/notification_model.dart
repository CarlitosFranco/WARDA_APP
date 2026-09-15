// ============================================================
// 📁 models/notification_model.dart
// Modelo de Notificación para WARDA
// ============================================================

class Notificacion {
  final String id;
  final String titulo;
  final String mensaje;
  final String tipo;
  bool leida;
  final DateTime fecha;
  final String? data;

  Notificacion({
    required this.id,
    required this.titulo,
    required this.mensaje,
    required this.tipo,
    this.leida = false,
    required this.fecha,
    this.data,
  });

  /// Convierte a Map para guardar en SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'mensaje': mensaje,
      'tipo': tipo,
      'leida': leida,
      'fecha': fecha.toIso8601String(),
      'data': data,
    };
  }

  /// Crea una instancia desde un Map (SQLite o JSON)
  factory Notificacion.fromMap(Map<String, dynamic> map) {
    return Notificacion(
      id: map['id'] ?? '',
      titulo: map['titulo'] ?? '',
      mensaje: map['mensaje'] ?? '',
      tipo: map['tipo'] ?? '',
      leida: map['leida'] ?? false,
      fecha: DateTime.parse(
        map['fecha'] ?? DateTime.now().toIso8601String(),
      ),
      data: map['data'],
    );
  }

  /// Copia con datos actualizados
  Notificacion copyWith({
    String? id,
    String? titulo,
    String? mensaje,
    String? tipo,
    bool? leida,
    DateTime? fecha,
    String? data,
  }) {
    return Notificacion(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      mensaje: mensaje ?? this.mensaje,
      tipo: tipo ?? this.tipo,
      leida: leida ?? this.leida,
      fecha: fecha ?? this.fecha,
      data: data ?? this.data,
    );
  }
}