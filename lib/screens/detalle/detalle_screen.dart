import 'package:flutter/material.dart';
import 'package:warda/models/reporte_model.dart';
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
                color: Helpers.getReporteColor(reporte.estado).withOpacity(0.2),
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
            // Botones de acción
            if (reporte.estado == 'pendiente' || reporte.estado == 'en proceso')
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Reportar en proceso',
                      onPressed: () {
                        // TODO: Actualizar estado
                        Helpers.showSnackBar(context, 'Estado actualizado');
                      },
                      isOutlined: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Resolver',
                      onPressed: () {
                        // TODO: Actualizar estado
                        Helpers.showSnackBar(context, 'Reporte resuelto');
                      },
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}