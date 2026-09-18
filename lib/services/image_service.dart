// ============================================================
// 📁 services/image_service.dart
// Manejo de cámara, galería y subida de imágenes al backend
// ============================================================

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:warda/services/token_storage.dart';
import 'package:warda/utils/constants.dart';

class ImageService {
  static final ImagePicker _picker = ImagePicker();

  // ============================================================
  // 📷 TOMAR FOTO CON LA CÁMARA
  // ============================================================
  static Future<File?> tomarFoto() async {
    try {
      final XFile? foto = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 75, // Comprimir un poco
        maxWidth: 1920,
      );

      if (foto == null) return null;
      return File(foto.path);
    } catch (e) {
      debugPrint('❌ Error al tomar foto: $e');
      return null;
    }
  }

  // ============================================================
  // 🖼️ SELECCIONAR IMAGEN DE LA GALERÍA
  // ============================================================
  static Future<File?> seleccionarDeGaleria() async {
    try {
      final XFile? foto = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
        maxWidth: 1920,
      );

      if (foto == null) return null;
      return File(foto.path);
    } catch (e) {
      debugPrint('❌ Error al seleccionar imagen: $e');
      return null;
    }
  }

  // ============================================================
  // 📤 SUBIR IMAGEN AL BACKEND
  // Retorna la URL pública de la imagen en el servidor
  // ============================================================
  static Future<String?> subirImagen(File imagen) async {
    try {
      final token = await TokenStorage.getToken();

      if (token == null) {
        debugPrint('❌ No hay token de sesión');
        return null;
      }

      // Detectar el tipo MIME del archivo
      final mimeType = lookupMimeType(imagen.path) ?? 'image/jpeg';
      final mimeParts = mimeType.split('/');

      // Crear la petición multipart
      final uri = Uri.parse('${AppConstants.apiUrl}/uploads');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(
          await http.MultipartFile.fromPath(
            'foto',
            imagen.path,
            contentType: MediaType(mimeParts[0], mimeParts[1]),
          ),
        );

      // Enviar la petición
      final streamedResponse = await request.send().timeout(
            const Duration(seconds: 30),
          );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final url = data['data']?['url'] as String?;
        debugPrint('✅ Imagen subida: $url');
        return url;
      } else {
        debugPrint('❌ Error al subir imagen: ${response.statusCode}');
        debugPrint('   Respuesta: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error al subir imagen: $e');
      return null;
    }
  }

  // ============================================================
  // 📤 SUBIR MÚLTIPLES IMÁGENES
  // Retorna lista de URLs públicas
  // ============================================================
  static Future<List<String>> subirMultiplesImagenes(
    List<File> imagenes,
  ) async {
    final urls = <String>[];

    for (final imagen in imagenes) {
      final url = await subirImagen(imagen);
      if (url != null) {
        urls.add(url);
      }
    }

    return urls;
  }
}