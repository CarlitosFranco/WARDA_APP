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
  String? _tipoSeleccionado;
  String? _ubicacion;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Reporte'),
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
              // Ubicación
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Ubicación',
                      hint: 'Ingresa la ubicación',
                      controller: TextEditingController(text: _ubicacion),
                      enabled: false,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    children: [
                      IconButton(
                        onPressed: () {
                          // TODO: Abrir mapa para seleccionar ubicación
                          Helpers.showSnackBar(context, 'Selecciona ubicación en el mapa');
                        },
                        icon: const Icon(Icons.map),
                        color: theme.colorScheme.primary,
                      ),
                      const Text(
                        'Mapa',
                        style: TextStyle(fontSize: 10),
                      ),
                    ],
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
                      onPressed: _isLoading ? null :() {_crearReporte ();},
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

  Future<void> _crearReporte() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final reporteProvider = Provider.of<ReporteProvider>(context, listen: false);

    final reporte = Reporte(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titulo: _tituloController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      tipo: _tipoSeleccionado!,
      estado: 'pendiente',
      fecha: DateTime.now(),
      ubicacion: _ubicacion,
      usuarioId: authProvider.usuarioActual!.id,
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
    super.dispose();
  }
}