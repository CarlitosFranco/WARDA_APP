import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:warda/models/usuario_model.dart';
import 'package:warda/models/reporte_model.dart';
import 'package:warda/models/notification_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'warda.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // ============================================================
  // 🏗️ CREACIÓN DE TABLAS
  // ============================================================
  Future<void> _onCreate(Database db, int version) async {
    // ---------- USUARIOS ----------
    await db.execute('''
      CREATE TABLE usuarios(
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        telefono TEXT NOT NULL,
        fotoUrl TEXT,
        notificacionesActivas INTEGER DEFAULT 1,
        ubicacionCompartida INTEGER DEFAULT 1,
        password TEXT NOT NULL
      )
    ''');

    // ---------- CONTACTOS DE EMERGENCIA ----------
    await db.execute('''
      CREATE TABLE contactos(
        id TEXT PRIMARY KEY,
        usuarioId TEXT NOT NULL,
        nombre TEXT NOT NULL,
        telefono TEXT NOT NULL,
        relacion TEXT NOT NULL,
        FOREIGN KEY (usuarioId) REFERENCES usuarios(id) ON DELETE CASCADE
      )
    ''');

    // ---------- REPORTES / INCIDENTES ----------
    await db.execute('''
      CREATE TABLE reportes(
        id TEXT PRIMARY KEY,
        usuarioId TEXT NOT NULL,
        titulo TEXT NOT NULL,
        descripcion TEXT NOT NULL,
        tipo TEXT NOT NULL,
        estado TEXT NOT NULL DEFAULT 'pendiente',
        fecha TEXT NOT NULL,
        ubicacion TEXT,
        latitud REAL,
        longitud REAL,
        imagenes TEXT,
        FOREIGN KEY (usuarioId) REFERENCES usuarios(id) ON DELETE CASCADE
      )
    ''');

    // ---------- NOTIFICACIONES ----------
    await db.execute('''
      CREATE TABLE notificaciones(
        id TEXT PRIMARY KEY,
        titulo TEXT NOT NULL,
        mensaje TEXT NOT NULL,
        tipo TEXT NOT NULL,
        leida INTEGER DEFAULT 0,
        fecha TEXT NOT NULL,
        data TEXT
      )
    ''');
  }

  // ============================================================
  // 👤 USUARIOS
  // ============================================================
  Future<void> insertUsuario(Usuario usuario, String password) async {
    final db = await database;
    await db.insert(
      'usuarios',
      {
        'id': usuario.id,
        'nombre': usuario.nombre,
        'email': usuario.email,
        'telefono': usuario.telefono,
        'fotoUrl': usuario.fotoUrl,
        'notificacionesActivas': usuario.notificacionesActivas ? 1 : 0,
        'ubicacionCompartida': usuario.ubicacionCompartida ? 1 : 0,
        'password': password,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Usuario?> getUsuarioByEmail(String email) async {
    final db = await database;
    final maps = await db.query(
      'usuarios',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isEmpty) return null;

    final usuario = _mapToUsuario(maps.first);
    usuario.contactosEmergencia
      ..clear()
      ..addAll(await getContactosByUsuario(usuario.id));
    return usuario;
  }

  Future<Usuario?> getUsuarioById(String id) async {
    final db = await database;
    final maps = await db.query(
      'usuarios',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;

    final usuario = _mapToUsuario(maps.first);
    usuario.contactosEmergencia
      ..clear()
      ..addAll(await getContactosByUsuario(usuario.id));
    return usuario;
  }

  Future<Usuario?> login(String email, String password) async {
    final db = await database;
    final maps = await db.query(
      'usuarios',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (maps.isEmpty) return null;

    final usuario = _mapToUsuario(maps.first);
    usuario.contactosEmergencia
      ..clear()
      ..addAll(await getContactosByUsuario(usuario.id));
    return usuario;
  }

  Future<bool> usuarioExiste(String email) async {
    final db = await database;
    final maps = await db.query(
      'usuarios',
      where: 'email = ?',
      whereArgs: [email],
    );
    return maps.isNotEmpty;
  }

  Future<void> updateUsuario(Usuario usuario) async {
    final db = await database;
    await db.update(
      'usuarios',
      {
        'nombre': usuario.nombre,
        'email': usuario.email,
        'telefono': usuario.telefono,
        'fotoUrl': usuario.fotoUrl,
        'notificacionesActivas': usuario.notificacionesActivas ? 1 : 0,
        'ubicacionCompartida': usuario.ubicacionCompartida ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [usuario.id],
    );
  }

  Usuario _mapToUsuario(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'] as String,
      nombre: map['nombre'] as String,
      email: map['email'] as String,
      telefono: map['telefono'] as String,
      fotoUrl: map['fotoUrl'] as String?,
      contactosEmergencia: [],
      notificacionesActivas: map['notificacionesActivas'] == 1,
      ubicacionCompartida: map['ubicacionCompartida'] == 1,
    );
  }

  // ============================================================
  // 📞 CONTACTOS DE EMERGENCIA
  // ============================================================
  Future<void> insertContacto(String usuarioId, ContactoEmergencia contacto) async {
    final db = await database;
    await db.insert(
      'contactos',
      {
        'id': contacto.id,
        'usuarioId': usuarioId,
        'nombre': contacto.nombre,
        'telefono': contacto.telefono,
        'relacion': contacto.relacion,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ContactoEmergencia>> getContactosByUsuario(String usuarioId) async {
    final db = await database;
    final maps = await db.query(
      'contactos',
      where: 'usuarioId = ?',
      whereArgs: [usuarioId],
    );
    return maps
        .map((m) => ContactoEmergencia(
              id: m['id'] as String,
              nombre: m['nombre'] as String,
              telefono: m['telefono'] as String,
              relacion: m['relacion'] as String,
            ))
        .toList();
  }

  Future<void> deleteContacto(String contactoId) async {
    final db = await database;
    await db.delete('contactos', where: 'id = ?', whereArgs: [contactoId]);
  }

  // ============================================================
  // 📝 REPORTES
  // ============================================================
  Future<void> insertReporte(Reporte reporte) async {
    final db = await database;
    await db.insert(
      'reportes',
      _reporteToMap(reporte),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Reporte>> getReportesByUsuario(String usuarioId) async {
    final db = await database;
    final maps = await db.query(
      'reportes',
      where: 'usuarioId = ?',
      whereArgs: [usuarioId],
      orderBy: 'fecha DESC',
    );
    return maps.map(_mapToReporte).toList();
  }

  Future<List<Reporte>> getAllReportes() async {
    final db = await database;
    final maps = await db.query('reportes', orderBy: 'fecha DESC');
    return maps.map(_mapToReporte).toList();
  }

  Future<void> updateReporte(Reporte reporte) async {
    final db = await database;
    await db.update(
      'reportes',
      _reporteToMap(reporte),
      where: 'id = ?',
      whereArgs: [reporte.id],
    );
  }

  Future<void> deleteReporte(String reporteId) async {
    final db = await database;
    await db.delete('reportes', where: 'id = ?', whereArgs: [reporteId]);
  }

  Map<String, dynamic> _reporteToMap(Reporte r) {
    return {
      'id': r.id,
      'usuarioId': r.usuarioId,
      'titulo': r.titulo,
      'descripcion': r.descripcion,
      'tipo': r.tipo,
      'estado': r.estado,
      'fecha': r.fecha.toIso8601String(),
      'ubicacion': r.ubicacion,
      'latitud': r.latitud,
      'longitud': r.longitud,
      'imagenes': r.imagenes != null ? r.imagenes!.join('|') : null,
    };
  }

  Reporte _mapToReporte(Map<String, dynamic> map) {
    return Reporte(
      id: map['id'] as String,
      usuarioId: map['usuarioId'] as String,
      titulo: map['titulo'] as String,
      descripcion: map['descripcion'] as String,
      tipo: map['tipo'] as String,
      estado: (map['estado'] as String?) ?? 'pendiente',
      fecha: DateTime.parse(map['fecha'] as String),
      ubicacion: map['ubicacion'] as String?,
      latitud: map['latitud'] != null ? (map['latitud'] as num).toDouble() : null,
      longitud: map['longitud'] != null ? (map['longitud'] as num).toDouble() : null,
      imagenes: (map['imagenes'] as String?)?.isNotEmpty == true
          ? (map['imagenes'] as String).split('|')
          : null,
    );
  }

  // ============================================================
  // 🔔 NOTIFICACIONES
  // ============================================================
  Future<void> insertNotificacion(Notificacion noti) async {
    final db = await database;
    await db.insert(
      'notificaciones',
      {
        'id': noti.id,
        'titulo': noti.titulo,
        'mensaje': noti.mensaje,
        'tipo': noti.tipo,
        'leida': noti.leida ? 1 : 0,
        'fecha': noti.fecha.toIso8601String(),
        'data': noti.data,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Notificacion>> getAllNotificaciones() async {
    final db = await database;
    final maps = await db.query('notificaciones', orderBy: 'fecha DESC');
    return maps
        .map((m) => Notificacion(
              id: m['id'] as String,
              titulo: m['titulo'] as String,
              mensaje: m['mensaje'] as String,
              tipo: m['tipo'] as String,
              leida: m['leida'] == 1,
              fecha: DateTime.parse(m['fecha'] as String),
              data: m['data'] as String?,
            ))
        .toList();
  }

  Future<void> marcarNotificacionLeida(String id) async {
    final db = await database;
    await db.update(
      'notificaciones',
      {'leida': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteNotificacion(String id) async {
    final db = await database;
    await db.delete('notificaciones', where: 'id = ?', whereArgs: [id]);
  }

  // ============================================================
  // 🧹 UTILIDADES
  // ============================================================
  Future<void> deleteAll() async {
    final db = await database;
    await db.delete('notificaciones');
    await db.delete('reportes');
    await db.delete('contactos');
    await db.delete('usuarios');
  }

  // ✅ CORREGIDO: ahora no hace await sobre _database (que es Database?, no Future)
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}