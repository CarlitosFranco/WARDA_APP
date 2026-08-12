import 'package:flutter/material.dart';
import 'package:warda/models/notificacion_model.dart';
import 'package:warda/utils/helpers.dart';

class NotificacionesScreen extends StatefulWidget {
  const NotificacionesScreen({super.key});

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  List<Notificacion> _notificaciones = [];

  @override
  void initState() {
    super.initState();
    _cargarNotificaciones();
  }

  void _cargarNotificaciones() {
    // Datos de ejemplo
    _notificaciones = [
      Notificacion(
        id: '1',
        titulo: '¡Bienvenido a WARDA!',
        mensaje: 'Gracias por unirte a nuestra comunidad de bienestar.',
        tipo: 'info',
        fecha: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      Notificacion(
        id: '2',
        titulo: 'Recordatorio de seguridad',
        mensaje: 'No olvides actualizar tus contactos de emergencia.',
        tipo: 'warning',
        fecha: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Notificacion(
        id: '3',
        titulo: 'Consejo del día',
        mensaje: 'Tómate 5 minutos para respirar profundamente.',
        tipo: 'info',
        fecha: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        actions: [
          if (_notificaciones.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  for (var notificacion in _notificaciones) {
                    notificacion.leida = true;
                  }
                });
              },
              child: const Text('Marcar todas como leídas'),
            ),
        ],
      ),
      body: _notificaciones.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes notificaciones',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Las notificaciones aparecerán aquí',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notificaciones.length,
              itemBuilder: (context, index) {
                final notificacion = _notificaciones[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: notificacion.leida
                      ? null
                      : theme.colorScheme.primary.withOpacity(0.05),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getColor(notificacion.tipo).withOpacity(0.2),
                      child: Icon(
                        _getIcon(notificacion.tipo),
                        color: _getColor(notificacion.tipo),
                      ),
                    ),
                    title: Text(
                      notificacion.titulo,
                      style: TextStyle(
                        fontWeight: notificacion.leida
                            ? FontWeight.normal
                            : FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(notificacion.mensaje),
                        const SizedBox(height: 4),
                        Text(
                          Helpers.formatRelativeDate(notificacion.fecha),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    trailing: notificacion.leida
                        ? null
                        : Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                    onTap: () {
                      setState(() {
                        notificacion.leida = true;
                      });
                      // TODO: Abrir detalle de notificación
                    },
                  ),
                );
              },
            ),
    );
  }

  Color _getColor(String tipo) {
    switch (tipo) {
      case 'info':
        return Colors.blue;
      case 'warning':
        return Colors.orange;
      case 'success':
        return Colors.green;
      case 'error':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getIcon(String tipo) {
    switch (tipo) {
      case 'info':
        return Icons.info_outline;
      case 'warning':
        return Icons.warning_outlined;
      case 'success':
        return Icons.check_circle_outline;
      case 'error':
        return Icons.error_outline;
      default:
        return Icons.notifications_outlined;
    }
  }
}