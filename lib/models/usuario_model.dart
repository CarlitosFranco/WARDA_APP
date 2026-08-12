// ============================================================
// 📁 models/usuario_model.dart
// Modelos de datos: Usuario y ContactoEmergencia
// ============================================================

class ContactoEmergencia {
  final String id;
  final String nombre;
  final String telefono;
  final String relacion;

  ContactoEmergencia({
    required this.id,
    required this.nombre,
    required this.telefono,
    required this.relacion,
  });

  /// Convierte a Map para almacenamiento en BD o SharedPreferences
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'telefono': telefono,
      'relacion': relacion,
    };
  }

  /// Crea una instancia desde un Map
  factory ContactoEmergencia.fromMap(Map<String, dynamic> map) {
    return ContactoEmergencia(
      id: map['id'] ?? '',
      nombre: map['nombre'] ?? '',
      telefono: map['telefono'] ?? '',
      relacion: map['relacion'] ?? '',
    );
  }

  /// Crea una copia con datos actualizados (útil para editar)
  ContactoEmergencia copyWith({
    String? id,
    String? nombre,
    String? telefono,
    String? relacion,
  }) {
    return ContactoEmergencia(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      telefono: telefono ?? this.telefono,
      relacion: relacion ?? this.relacion,
    );
  }
}

class Usuario {
  final String id;
  final String nombre;
  final String email;
  final String telefono;
  final String? fotoUrl;
  List<ContactoEmergencia> contactosEmergencia;
  final bool notificacionesActivas;
  final bool ubicacionCompartida;

  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    required this.telefono,
    this.fotoUrl,
    this.contactosEmergencia = const [],
    this.notificacionesActivas = true,
    this.ubicacionCompartida = true,
  });

  /// Convierte a Map para almacenamiento
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'telefono': telefono,
      'fotoUrl': fotoUrl,
      'contactosEmergencia': contactosEmergencia.map((c) => c.toMap()).toList(),
      'notificacionesActivas': notificacionesActivas,
      'ubicacionCompartida': ubicacionCompartida,
    };
  }

  /// Crea una instancia desde un Map
  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'] ?? '',
      nombre: map['nombre'] ?? '',
      email: map['email'] ?? '',
      telefono: map['telefono'] ?? '',
      fotoUrl: map['fotoUrl'],
      contactosEmergencia: map['contactosEmergencia'] != null
          ? List<ContactoEmergencia>.from(
              (map['contactosEmergencia'] as List).map(
                (c) => ContactoEmergencia.fromMap(c as Map<String, dynamic>),
              ),
            )
          : [],
      notificacionesActivas: map['notificacionesActivas'] ?? true,
      ubicacionCompartida: map['ubicacionCompartida'] ?? true,
    );
  }

  /// Crea una copia con datos actualizados
  Usuario copyWith({
    String? id,
    String? nombre,
    String? email,
    String? telefono,
    String? fotoUrl,
    List<ContactoEmergencia>? contactosEmergencia,
    bool? notificacionesActivas,
    bool? ubicacionCompartida,
  }) {
    return Usuario(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      contactosEmergencia: contactosEmergencia ?? this.contactosEmergencia,
      notificacionesActivas: notificacionesActivas ?? this.notificacionesActivas,
      ubicacionCompartida: ubicacionCompartida ?? this.ubicacionCompartida,
    );
  }
}