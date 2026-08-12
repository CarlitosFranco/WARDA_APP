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
      'imagenes': imagenes,
      'usuarioId': usuarioId,
    };
  }

  factory Reporte.fromMap(Map<String, dynamic> map) {
    return Reporte(
      id: map['id'] ?? '',
      titulo: map['titulo'] ?? '',
      descripcion: map['descripcion'] ?? '',
      tipo: map['tipo'] ?? '',
      estado: map['estado'] ?? 'pendiente',
      fecha: DateTime.parse(map['fecha'] ?? DateTime.now().toIso8601String()),
      ubicacion: map['ubicacion'],
      latitud: map['latitud']?.toDouble(),
      longitud: map['longitud']?.toDouble(),
      imagenes: map['imagenes'] != null ? List<String>.from(map['imagenes']) : null,
      usuarioId: map['usuarioId'] ?? '',
    );
  }
}