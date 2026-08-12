// ============================================
// 🚫 MAPA DESACTIVADO TEMPORALMENTE
// ============================================
// TODO: Reactivar cuando se tenga API Key de Google Maps

/*
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapWidget extends StatefulWidget {
  final LatLng? initialPosition;
  final List<Marker> markers;
  final bool showUserLocation;
  final Function(LatLng)? onTap;

  const MapWidget({
    super.key,
    this.initialPosition,
    this.markers = const [],
    this.showUserLocation = true,
    this.onTap,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  late GoogleMapController _controller;
  late LatLng _currentPosition;

  @override
  void initState() {
    super.initState();
    _currentPosition = widget.initialPosition ?? const LatLng(-12.0464, -77.0428);
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _currentPosition,
        zoom: 15,
      ),
      markers: Set<Marker>.of(widget.markers),
      myLocationEnabled: widget.showUserLocation,
      myLocationButtonEnabled: widget.showUserLocation,
      onMapCreated: (controller) {
        _controller = controller;
      },
      onTap: (position) {
        if (widget.onTap != null) {
          widget.onTap!(position);
        }
      },
    );
  }

  void moveCamera(LatLng position, {double zoom = 15}) {
    _controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: position,
          zoom: zoom,
        ),
      ),
    );
  }
}
*/