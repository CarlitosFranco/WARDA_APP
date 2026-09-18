import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warda/models/reporte_model.dart';
import 'package:warda/providers/reporte_provider.dart';
import 'package:warda/utils/helpers.dart';
import 'package:warda/widgets/custom_button.dart';

class DetalleScreen extends StatelessWidget {
  const DetalleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reporte = ModalRoute.of(context)!.settings.arguments as Reporte;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(reporte.titulo),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Estado
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Helpers.getReporteColor(reporte.estado)
                    .withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.circle,
                    size: 12,
                    color: Helpers.getReporteColor(reporte.estado),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    reporte.estado.toUpperCase(),
                    style: TextStyle(
                      color: Helpers.getReporteColor(reporte.estado),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Tipo
            Row(
              children: [
                const Icon(Icons.label_outline, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Tipo: ${reporte.tipo}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Fecha
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Creado: ${Helpers.formatDate(reporte.fecha)}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),

            // Ubicación
            if (reporte.ubicacion != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ubicación: ${reporte.ubicacion}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ],

            // ============================================================
            // 📷 FOTOS DEL REPORTE
            // ============================================================
            if (reporte.imagenes != null && reporte.imagenes!.isNotEmpty) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  const Icon(Icons.photo_library, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Fotos (${reporte.imagenes!.length})',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 160,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: reporte.imagenes!.length,
                  itemBuilder: (context, index) {
                    final url = reporte.imagenes![index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () => _abrirVisorCompleto(context, url),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: url,
                            width: 160,
                            height: 160,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              width: 160,
                              height: 160,
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              width: 160,
                              height: 160,
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Descripción
            Text(
              'Descripción',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  reporte.descripcion,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ============================================================
            // 🔄 BOTONES DE ACCIÓN (actualizan estado en el backend)
            // ============================================================
            if (reporte.estado == 'pendiente' ||
                reporte.estado == 'en_proceso') ...[
              Text(
                'Acciones',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (reporte.estado == 'pendiente')
                    Expanded(
                      child: CustomButton(
                        text: 'En proceso',
                        onPressed: () => _cambiarEstado(
                          context,
                          reporte.id,
                          'en_proceso',
                          'Estado actualizado a "En proceso"',
                        ),
                        isOutlined: true,
                      ),
                    ),
                  if (reporte.estado == 'pendiente') const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Resolver',
                      onPressed: () => _cambiarEstado(
                        context,
                        reporte.id,
                        'resuelto',
                        'Reporte marcado como "Resuelto"',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 🖼️ VISOR DE IMAGEN A PANTALLA COMPLETA
  // ============================================================
  void _abrirVisorCompleto(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _VisorImagenCompleta(url: url),
      ),
    );
  }

  // ============================================================
  // 🔄 CAMBIAR ESTADO DEL REPORTE
  // ============================================================
  Future<void> _cambiarEstado(
    BuildContext context,
    String reporteId,
    String nuevoEstado,
    String mensajeExito,
  ) async {
    final provider = Provider.of<ReporteProvider>(context, listen: false);

    final success = await provider.actualizarEstado(reporteId, nuevoEstado);

    if (context.mounted) {
      if (success) {
        Helpers.showSnackBar(
          context,
          '✅ $mensajeExito',
          color: Colors.green,
        );
        Navigator.pop(context);
      } else {
        Helpers.showSnackBar(
          context,
          '❌ Error al actualizar: ${provider.error}',
          color: Colors.red,
        );
      }
    }
  }
}

// ============================================================
// 🖼️ WIDGET: VISOR DE IMAGEN A PANTALLA COMPLETA
// ============================================================
class _VisorImagenCompleta extends StatelessWidget {
  final String url;

  const _VisorImagenCompleta({required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.contain,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
            errorWidget: (context, url, error) => const Center(
              child: Icon(
                Icons.broken_image,
                size: 80,
                color: Colors.white54,
              ),
            ),
          ),
        ),
      ),
    );
  }
}