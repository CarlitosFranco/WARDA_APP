import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:warda/services/location_service.dart';
import 'package:geolocator/geolocator.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  LatLng? _currentPosition;
  bool _isLoading = true;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    setState(() => _isLoading = true);
    
    // Solicitar permiso
    final hasPermission = await LocationService.requestPermission();
    if (!hasPermission) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Permiso de ubicación denegado'),
          backgroundColor: Colors.red,
        ),
      );
      // Ubicación por defecto (Lima, Perú)
      _currentPosition = const LatLng(-12.0464, -77.0428);
      setState(() => _isLoading = false);
      return;
    }

    // Obtener ubicación
    final position = await LocationService.getCurrentLocation();
    if (position != null) {
      _currentPosition = LatLng(position.latitude, position.longitude);
    } else {
      // Ubicación por defecto
      _currentPosition = const LatLng(-12.0464, -77.0428);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ No se pudo obtener ubicación, mostrando Lima'),
          backgroundColor: Colors.orange,
        ),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Riesgos'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _getUserLocation,
            tooltip: 'Centrar mi ubicación',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentPosition ?? const LatLng(-12.0464, -77.0428),
                initialZoom: 14.0,
                minZoom: 5.0,
                maxZoom: 18.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
                onPositionChanged: (position, hasGesture) {
                  // Aquí podrías cargar incidentes cercanos
                },
              ),
              children: [
                // Capa de tiles (OpenStreetMap)
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.warda',
                  tileProvider: NetworkTileProvider(),
                ),
                
                // Marcador de ubicación actual
                if (_currentPosition != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 50,
                        height: 50,
                        point: _currentPosition!,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                
                // 🔥 Capa de calor (opcional, para incidentes)
                // Aquí puedes agregar marcadores de incidentes más tarde
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Centrar en ubicación actual
          if (_currentPosition != null) {
            _mapController.move(_currentPosition!, 14.0);
          }
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.center_focus_strong, color: Colors.white),
      ),
    );
  }
}