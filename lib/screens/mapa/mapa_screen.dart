import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:warda/models/reporte_model.dart';
import 'package:warda/providers/auth_provider.dart';
import 'package:warda/providers/reporte_provider.dart';
import 'package:warda/services/location_service.dart';
import 'package:warda/utils/helpers.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  LatLng? _currentPosition;
  bool _isLoading = true;
  List<Reporte> _incidentes = [];
  final MapController _mapController = MapController();

  bool _modoSeleccion = false;
  LatLng? _puntoSeleccionado;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getUserLocation();
      _cargarIncidentes();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is bool && args == true) {
      _modoSeleccion = true;
    }
  }

  // ============================================================
  // 📍 OBTENER UBICACIÓN DEL USUARIO
  // ============================================================
  Future<void> _getUserLocation() async {
    setState(() => _isLoading = true);
    final position = await LocationService.getCurrentLocation();
    if (position != null) {
      _currentPosition = LatLng(position.latitude, position.longitude);
    } else {
      _currentPosition = const LatLng(-12.0464, -77.0428);
      if (mounted) {
        Helpers.showSnackBar(
          context,
          '⚠️ Usando ubicación por defecto (Lima)',
          color: Colors.orange,
        );
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  // ============================================================
  // 📋 CARGAR TODOS LOS INCIDENTES (para el heatmap completo)
  // ============================================================
  Future<void> _cargarIncidentes() async {
    final provider = Provider.of<ReporteProvider>(context, listen: false);

    // ✅ Cargar TODOS los reportes (no solo los del usuario)
    // porque el heatmap muestra zonas de riesgo de toda la comunidad
    await provider.cargarTodosReportes();

    if (mounted) {
      setState(() {
        _incidentes = provider.reportes;
      });
    }
  }

  // ============================================================
  // 🎨 COLORES E ÍCONOS SEGÚN TIPO
  // ============================================================
  Color _getColorPorTipo(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'robo':
      case 'asalto':
        return Colors.red;
      case 'vandalismo':
        return Colors.orange;
      case 'accidente':
        return Colors.yellow;
      case 'violencia':
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }

  IconData _getIconPorTipo(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'robo':
      case 'asalto':
        return Icons.local_police;
      case 'vandalismo':
        return Icons.broken_image;
      case 'accidente':
        return Icons.car_crash;
      case 'violencia':
        return Icons.warning_amber;
      default:
        return Icons.warning;
    }
  }

  // ============================================================
  // 🔥 GENERAR CAPA DE HEATMAP
  // Crea círculos concéntricos por cada incidente para simular
  // un mapa de calor. Cuando varios se superponen, el color
  // se intensifica = zona de mayor riesgo.
  // ============================================================
  List<CircleMarker> _buildHeatmapCircles() {
    final circles = <CircleMarker>[];

    for (final incidente in _incidentes) {
      if (incidente.latitud == null || incidente.longitud == null) continue;

      final point = LatLng(incidente.latitud!, incidente.longitud!);

      // 🔴 Capa 1: rojo intenso (núcleo del incidente)
      circles.add(CircleMarker(
        point: point,
        radius: 150, // metros
        useRadiusInMeter: true,
        color: Colors.red.withValues(alpha: 0.5),
        borderStrokeWidth: 0,
      ));

      // 🟠 Capa 2: naranja (zona caliente)
      circles.add(CircleMarker(
        point: point,
        radius: 300,
        useRadiusInMeter: true,
        color: Colors.orange.withValues(alpha: 0.3),
        borderStrokeWidth: 0,
      ));

      // 🟡 Capa 3: amarillo (zona templada)
      circles.add(CircleMarker(
        point: point,
        radius: 500,
        useRadiusInMeter: true,
        color: Colors.yellow.withValues(alpha: 0.2),
        borderStrokeWidth: 0,
      ));

      // 🟢 Capa 4: verde (zona de influencia)
      circles.add(CircleMarker(
        point: point,
        radius: 750,
        useRadiusInMeter: true,
        color: Colors.green.withValues(alpha: 0.1),
        borderStrokeWidth: 0,
      ));
    }

    return circles;
  }

  // ============================================================
  // 📝 MOSTRAR DETALLE DEL INCIDENTE
  // ============================================================
  void _mostrarDetalleIncidente(BuildContext context, Reporte incidente) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getIconPorTipo(incidente.tipo),
                  color: _getColorPorTipo(incidente.tipo),
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    incidente.titulo,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            Text('📌 Tipo: ${incidente.tipo}'),
            Text('📅 ${Helpers.formatDate(incidente.fecha)}'),
            if (incidente.ubicacion != null) Text('📍 ${incidente.ubicacion}'),
            const SizedBox(height: 12),
            Text(
              incidente.descripcion,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Helpers.getReporteColor(incidente.estado)
                    .withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Estado: ${incidente.estado.toUpperCase()}',
                style: TextStyle(
                  color: Helpers.getReporteColor(incidente.estado),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Cerrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 🏗️ BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_modoSeleccion ? 'Seleccionar ubicación' : 'Mapa de Calor'),
        backgroundColor: _modoSeleccion ? Colors.green : Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          if (_modoSeleccion && _puntoSeleccionado != null)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                Navigator.pop(context, {
                  'latitud': _puntoSeleccionado!.latitude,
                  'longitud': _puntoSeleccionado!.longitude,
                });
              },
              tooltip: 'Confirmar ubicación',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _cargarIncidentes();
              Helpers.showSnackBar(context, '🔄 Incidentes actualizados',
                  color: Colors.blue);
            },
            tooltip: 'Actualizar incidentes',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // ============================================
                // 🗺️ MAPA CON HEATMAP
                // ============================================
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter:
                        _currentPosition ?? const LatLng(-12.0464, -77.0428),
                    initialZoom: 14.0,
                    minZoom: 5.0,
                    maxZoom: 18.0,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all,
                    ),
                    onTap: (tapPosition, point) {
                      if (_modoSeleccion) {
                        setState(() {
                          _puntoSeleccionado = point;
                        });
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.warda',
                      tileProvider: NetworkTileProvider(),
                    ),

                    // 🔥 CAPA DE HEATMAP (siempre visible)
                    if (_incidentes.isNotEmpty)
                      CircleLayer(
                        circles: _buildHeatmapCircles(),
                      ),

                    // 📍 Marcador de ubicación actual
                    if (_currentPosition != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 50,
                            height: 50,
                            point: _currentPosition!,
                            alignment: Alignment.center,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.blue,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withValues(alpha: 0.4),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.my_location,
                                color: Colors.blue,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),

                    // 📌 Marcadores de incidentes (encima del heatmap)
                    if (_incidentes.isNotEmpty)
                      MarkerLayer(
                        markers: _incidentes.map((incidente) {
                          if (incidente.latitud == null ||
                              incidente.longitud == null) {
                            return null;
                          }
                          final color = _getColorPorTipo(incidente.tipo);
                          final icon = _getIconPorTipo(incidente.tipo);
                          return Marker(
                            width: 45,
                            height: 45,
                            point: LatLng(
                                incidente.latitud!, incidente.longitud!),
                            alignment: Alignment.center,
                            child: GestureDetector(
                              onTap: () =>
                                  _mostrarDetalleIncidente(context, incidente),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black
                                          .withValues(alpha: 0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  icon,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                          );
                        }).whereType<Marker>().toList(),
                      ),

                    // 🟢 Marcador de selección
                    if (_modoSeleccion && _puntoSeleccionado != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 60,
                            height: 60,
                            point: _puntoSeleccionado!,
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.location_pin,
                              color: Colors.green,
                              size: 50,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                // ============================================
                // 📊 CONTADOR DE INCIDENTES (esquina inferior izquierda)
                // ============================================
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _modoSeleccion
                          ? Colors.green.shade700
                          : Colors.deepOrange.shade700,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Text(
                      _modoSeleccion
                          ? (_puntoSeleccionado != null
                              ? '✅ Ubicación seleccionada'
                              : '👆 Toca el mapa para elegir')
                          : '${_incidentes.length} incidentes',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // ============================================
                // 🔥 LEYENDA DEL HEATMAP (esquina inferior derecha)
                // ============================================
                if (!_modoSeleccion)
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            '🔥 Nivel de riesgo',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          _buildLeyendaItem(Colors.green, 'Bajo'),
                          _buildLeyendaItem(Colors.yellow[700]!, 'Medio'),
                          _buildLeyendaItem(Colors.orange, 'Alto'),
                          _buildLeyendaItem(Colors.red, 'Muy alto'),
                        ],
                      ),
                    ),
                  ),

                // ============================================
                // 🟢 BOTÓN CONFIRMAR (solo en modo selección)
                // ============================================
                if (_modoSeleccion && _puntoSeleccionado != null)
                  Positioned(
                    bottom: 80,
                    right: 20,
                    child: FloatingActionButton.extended(
                      onPressed: () {
                        Navigator.pop(context, {
                          'latitud': _puntoSeleccionado!.latitude,
                          'longitud': _puntoSeleccionado!.longitude,
                        });
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Confirmar'),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
      floatingActionButton: !_modoSeleccion
          ? FloatingActionButton(
              onPressed: () {
                if (_currentPosition != null) {
                  _mapController.move(_currentPosition!, 14.0);
                }
              },
              backgroundColor: Colors.deepOrange,
              child:
                  const Icon(Icons.center_focus_strong, color: Colors.white),
            )
          : null,
    );
  }

  // ============================================================
  // 🎨 HELPER: ITEM DE LEYENDA
  // ============================================================
  Widget _buildLeyendaItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.7),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}