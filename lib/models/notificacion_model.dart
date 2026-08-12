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

  factory Notificacion.fromMap(Map<String, dynamic> map) {
    return Notificacion(
      id: map['id'] ?? '',
      titulo: map['titulo'] ?? '',
      mensaje: map['mensaje'] ?? '',
      tipo: map['tipo'] ?? '',
      leida: map['leida'] ?? false,
      fecha: DateTime.parse(map['fecha'] ?? DateTime.now().toIso8601String()),
      data: map['data'],
    );
  }
}