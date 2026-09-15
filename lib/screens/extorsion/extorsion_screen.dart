import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class ExtortionScreen extends StatefulWidget {
  const ExtortionScreen({super.key});

  @override
  State<ExtortionScreen> createState() => _ExtortionScreenState();
}

class _ExtortionScreenState extends State<ExtortionScreen> {
  final _direccionController = TextEditingController();
  final _numerosController = TextEditingController();
  final _montoController = TextEditingController();
  final _relatoController = TextEditingController();

  String? _rubroSeleccionado;
  String? _medioSeleccionado;
  String? _inicioSeleccionado;
  String? _frecuenciaSeleccionada;
  String? _medioPagoSeleccionado;

  bool _extorsionDirecta = false;
  bool _denunciaPolicial = false;
  bool _pagandoExtorsion = false;

  // Variables para el mapa
  final MapController _mapController = MapController();
  LatLng _currentPosition = const LatLng(-12.046374, -77.042793); // Lima, Perú
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _determinePosition();
    });
  }

  /// Función para obtener la ubicación GPS real del dispositivo
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          setState(() => _isLoadingLocation = false);
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    if (mounted) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });
      _mapController.move(_currentPosition, 16.0);
    }
  }

  @override
  void dispose() {
    _direccionController.dispose();
    _numerosController.dispose();
    _montoController.dispose();
    _relatoController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Denuncia de Extorsión'),
        backgroundColor: Colors.deepOrange.shade700,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // MAPA INTERACTIVO (OpenStreetMap)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 180,
                width: double.infinity,
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _currentPosition,
                        initialZoom: 15.0,
                        onTap: (tapPosition, point) {
                          setState(() {
                            _currentPosition = point;
                          });
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.warda',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _currentPosition,
                              width: 40,
                              height: 40,
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (_isLoadingLocation)
                      Container(
                        color: Colors.black.withOpacity(0.25),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: FloatingActionButton.small(
                        heroTag: 'btn_my_location',
                        onPressed: _determinePosition,
                        backgroundColor: Colors.deepOrange,
                        child: const Icon(Icons.my_location, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            _buildLabel('Dirección o referencia del lugar*'),
            TextField(
              controller: _direccionController,
              decoration: const InputDecoration(
                hintText: 'Escriba la descripción del lugar',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            _buildLabel('Rubro por el que te extorsionan*'),
            DropdownButtonFormField<String>(
              value: _rubroSeleccionado,
              hint: const Text('Seleccione una opción'),
              items: ['Comercio', 'Transporte', 'Personal', 'Otro']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => _rubroSeleccionado = val),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),

            _buildLabel('¿La extorsión se hace directamente a ti?'),
            Row(
              children: [
                Radio<bool>(
                  value: true,
                  groupValue: _extorsionDirecta,
                  onChanged: (v) => setState(() => _extorsionDirecta = v!),
                ),
                const Text('Sí'),
                Radio<bool>(
                  value: false,
                  groupValue: _extorsionDirecta,
                  onChanged: (v) => setState(() => _extorsionDirecta = v!),
                ),
                const Text('No'),
              ],
            ),

            _buildLabel('¿Realizaste denuncia policial?'),
            Row(
              children: [
                Radio<bool>(
                  value: true,
                  groupValue: _denunciaPolicial,
                  onChanged: (v) => setState(() => _denunciaPolicial = v!),
                ),
                const Text('Sí'),
                Radio<bool>(
                  value: false,
                  groupValue: _denunciaPolicial,
                  onChanged: (v) => setState(() => _denunciaPolicial = v!),
                ),
                const Text('No'),
              ],
            ),
            const SizedBox(height: 16),

            _buildLabel('Desde qué medio te extorsionan*'),
            DropdownButtonFormField<String>(
              value: _medioSeleccionado,
              hint: const Text('Seleccione una opción'),
              items: ['Llamada', 'WhatsApp', 'Presencial', 'Redes Sociales']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => _medioSeleccionado = val),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),

            _buildLabel('Indica los números, correos o perfil de red social desde donde recibes amenazas'),
            TextField(
              controller: _numerosController,
              decoration: const InputDecoration(
                hintText: 'Indica el correo, número, etc.',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            _buildLabel('¿Cuándo comenzó la extorsión?'),
            DropdownButtonFormField<String>(
              value: _inicioSeleccionado,
              hint: const Text('Seleccione una opción'),
              items: ['Hoy', 'Esta semana', 'Hace un mes', 'Hace más de un mes']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => _inicioSeleccionado = val),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),

            _buildLabel('¿Cuántas veces te han amenazado?'),
            DropdownButtonFormField<String>(
              value: _frecuenciaSeleccionada,
              hint: const Text('Seleccione una opción'),
              items: ['1 vez', '2-5 veces', 'Constante']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => _frecuenciaSeleccionada = val),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),

            _buildLabel('Monto'),
            TextField(
              controller: _montoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Monto',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            _buildLabel('Medio de pago'),
            DropdownButtonFormField<String>(
              value: _medioPagoSeleccionado,
              hint: const Text('Seleccione una opción'),
              items: ['Efectivo', 'Transferencia/Yape/Plin', 'Criptomonedas', 'Otro']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => _medioPagoSeleccionado = val),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),

            _buildLabel('Relato de la extorsión (500 caracteres)*'),
            TextField(
              controller: _relatoController,
              maxLines: 4,
              maxLength: 500,
              decoration: const InputDecoration(
                hintText: 'Ingrese más detalle para la denuncia',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            _buildLabel('Agrega evidencias*'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(icon: const Icon(Icons.image, size: 36), onPressed: () {}),
                IconButton(icon: const Icon(Icons.camera_alt, size: 36), onPressed: () {}),
                IconButton(icon: const Icon(Icons.description, size: 36), onPressed: () {}),
              ],
            ),
            const SizedBox(height: 16),

            _buildLabel('¿Ya estás pagando por la extorsión?'),
            Row(
              children: [
                Radio<bool>(
                  value: true,
                  groupValue: _pagandoExtorsion,
                  onChanged: (v) => setState(() => _pagandoExtorsion = v!),
                ),
                const Text('Sí'),
                Radio<bool>(
                  value: false,
                  groupValue: _pagandoExtorsion,
                  onChanged: (v) => setState(() => _pagandoExtorsion = v!),
                ),
                const Text('No'),
              ],
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Denuncia enviada (simulación)'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: const Text(
                  'Enviar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }
}