import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warda/models/reporte_model.dart';
import 'package:warda/providers/auth_provider.dart';
import 'package:warda/providers/reporte_provider.dart';
import 'package:warda/widgets/custom_button.dart';
import 'package:warda/widgets/custom_textfield.dart';
import 'package:warda/utils/constants.dart';
import 'package:warda/utils/helpers.dart';
import 'dart:async';

class CrearReporteScreen extends StatefulWidget {
  const CrearReporteScreen({super.key});

  @override
  State<CrearReporteScreen> createState() => _CrearReporteScreenState();
}

class _CrearReporteScreenState extends State<CrearReporteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _ubicacionController = TextEditingController();
  String? _tipoSeleccionado;
  double? _latitud;
  double? _longitud;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Reporte'),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nuevo reporte',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Describe la situación para recibir ayuda',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              // Título
              CustomTextField(
                label: 'Título',
                hint: 'Escribe un título descriptivo',
                controller: _tituloController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El título es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Tipo
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Tipo de reporte',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                ),
                value: _tipoSeleccionado,
                items: AppConstants.tiposReporte.map((tipo) {
                  return DropdownMenuItem(
                    value: tipo,
                    child: Text(tipo),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _tipoSeleccionado = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Selecciona un tipo de reporte';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Descripción
              CustomTextField(
                label: 'Descripción',
                hint: 'Describe detalladamente la situación',
                controller: _descripcionController,
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La descripción es requerida';
                  }
                  if (value.length < 10) {
                    return 'La descripción debe tener al menos 10 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Ubicación (dirección + coordenadas)
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: CustomTextField(
                      label: 'Ubicación (dirección)',
                      hint: 'Ej: Av. Principal 123',
                      controller: _ubicacionController,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        IconButton(
                          onPressed: _seleccionarUbicacionEnMapa,
                          icon: const Icon(Icons.map),
                          color: Colors.green,
                          tooltip: 'Seleccionar en el mapa',
                        ),
                        const Text(
                          'Mapa',
                          style: TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Mostrar latitud y longitud (informativas)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _latitud != null
                          ? '📌 Lat: ${_latitud!.toStringAsFixed(6)}'
                          : '📍 Sin coordenadas',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _longitud != null
                          ? '📌 Lng: ${_longitud!.toStringAsFixed(6)}'
                          : '',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Botones
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Cancelar',
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      isOutlined: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Enviar reporte',
                      onPressed: _isLoading ? null : _crearReporte,
                      isLoading: _isLoading,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 🗺️ ABRIR MAPA PARA SELECCIONAR UBICACIÓN
  // ============================================================
  Future<void> _seleccionarUbicacionEnMapa() async {
    // Navegar al mapa en modo selección
    final resultado = await Navigator.pushNamed(
      context,
      '/mapa',
      arguments: true, // Activa modo selección
    );

    if (resultado != null && resultado is Map<String, double>) {
      setState(() {
        _latitud = resultado['latitud'];
        _longitud = resultado['longitud'];
        // Opcional: puedes usar geocodificación inversa para obtener dirección
        // Por ahora, dejamos que el usuario escriba la dirección manualmente
        _ubicacionController.text =
            'Ubicación seleccionada (${_latitud!.toStringAsFixed(4)}, ${_longitud!.toStringAsFixed(4)})';
      });
      Helpers.showSnackBar(
        context,
        '📍 Ubicación seleccionada correctamente',
        color: Colors.green,
      );
    }
  }

  // ============================================================
  // 📤 CREAR REPORTE
  // ============================================================
  Future<void> _crearReporte() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validar coordenadas (opcional pero recomendado)
    if (_latitud == null || _longitud == null) {
      Helpers.showSnackBar(
        context,
        '⚠️ Debes seleccionar una ubicación en el mapa',
        color: Colors.orange,
      );
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final reporteProvider = Provider.of<ReporteProvider>(context, listen: false);

    // Obtener ID del usuario (con fallback a invitado)
    final usuarioId = authProvider.usuarioActual?.id ??
        'invitado_${DateTime.now().millisecondsSinceEpoch}';

    final reporte = Reporte(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titulo: _tituloController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      tipo: _tipoSeleccionado!,
      estado: 'pendiente',
      fecha: DateTime.now(),
      ubicacion: _ubicacionController.text.trim().isEmpty
          ? 'Ubicación seleccionada'
          : _ubicacionController.text.trim(),
      latitud: _latitud,
      longitud: _longitud,
      imagenes: null,
      usuarioId: usuarioId,
    );

    final success = await reporteProvider.crearReporte(reporte);

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        Helpers.showSnackBar(
          context,
          '✅ Reporte creado exitosamente',
          color: Colors.green,
        );
        Navigator.pop(context, true);
      }
    } else {
      if (mounted) {
        Helpers.showSnackBar(
          context,
          '❌ Error al crear el reporte: ${reporteProvider.error}',
          color: Colors.red,
        );
      }
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _ubicacionController.dispose();
    super.dispose();
  }
}