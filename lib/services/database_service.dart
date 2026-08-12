import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:warda/models/usuario_model.dart';

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

  Future<void> _onCreate(Database db, int version) async {
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
  }

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
    final List<Map<String, dynamic>> maps = await db.query(
      'usuarios',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isEmpty) return null;

    return Usuario(
      id: maps.first['id'],
      nombre: maps.first['nombre'],
      email: maps.first['email'],
      telefono: maps.first['telefono'],
      fotoUrl: maps.first['fotoUrl'],
      contactosEmergencia: [],
      notificacionesActivas: maps.first['notificacionesActivas'] == 1,
      ubicacionCompartida: maps.first['ubicacionCompartida'] == 1,
    );
  }

  Future<Usuario?> login(String email, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'usuarios',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (maps.isEmpty) return null;

    return Usuario(
      id: maps.first['id'],
      nombre: maps.first['nombre'],
      email: maps.first['email'],
      telefono: maps.first['telefono'],
      fotoUrl: maps.first['fotoUrl'],
      contactosEmergencia: [],
      notificacionesActivas: maps.first['notificacionesActivas'] == 1,
      ubicacionCompartida: maps.first['ubicacionCompartida'] == 1,
    );
  }

  Future<bool> usuarioExiste(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'usuarios',
      where: 'email = ?',
      whereArgs: [email],
    );
    return maps.isNotEmpty;
  }

  Future<void> deleteAll() async {
    final db = await database;
    await db.delete('contactos');
    await db.delete('usuarios');
  }
}