// ============================================================
// 📁 models/usuario_model.dart
// Modelos de datos: Usuario y ContactoEmergencia
// Compatible con SQLite
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

  /// Convierte a Map para guardar en SQLite (tabla `contactos`)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'telefono': telefono,
      'relacion': relacion,
    };
  }

  /// Crea una instancia desde un Map (SQLite o JSON)
  factory ContactoEmergencia.fromMap(Map<String, dynamic> map) {
    return ContactoEmergencia(
      id: (map['id'] ?? '').toString(),
      nombre: (map['nombre'] ?? '').toString(),
      telefono: (map['telefono'] ?? '').toString(),
      relacion: (map['relacion'] ?? '').toString(),
    );
  }

  /// Crea una copia con datos actualizados
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

  @override
  String toString() {
    return 'ContactoEmergencia(id: $id, nombre: $nombre, tel: $telefono, relacion: $relacion)';
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

  /// Convierte a Map SOLO con las columnas de la tabla `usuarios`.
  /// ⚠️ NO incluye `contactosEmergencia` porque van en otra tabla.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'telefono': telefono,
      'fotoUrl': fotoUrl,
      'notificacionesActivas': notificacionesActivas ? 1 : 0,
      'ubicacionCompartida': ubicacionCompartida ? 1 : 0,
    };
  }

  /// Crea una instancia desde un Map (SQLite o JSON).
  /// Los contactos de emergencia se cargan por separado con el DatabaseService.
  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: (map['id'] ?? '').toString(),
      nombre: (map['nombre'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      telefono: (map['telefono'] ?? '').toString(),
      fotoUrl: map['fotoUrl'] as String?,
      contactosEmergencia: const [], // Se cargan aparte desde la tabla `contactos`
      notificacionesActivas: _parseBool(map['notificacionesActivas'], true),
      ubicacionCompartida: _parseBool(map['ubicacionCompartida'], true),
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

  @override
  String toString() {
    return 'Usuario(id: $id, nombre: $nombre, email: $email, tel: $telefono)';
  }
}

// ============================================================
// 🛠️ HELPER: Convierte 0/1/true/false/null a bool de forma segura
// ============================================================
bool _parseBool(dynamic value, [bool defaultValue = true]) {
  if (value == null) return defaultValue;
  if (value is bool) return value;
  if (value is int) return value == 1;
  if (value is String) {
    final lower = value.toLowerCase();
    return lower == '1' || lower == 'true';
  }
  return defaultValue;
}