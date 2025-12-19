import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/themes.dart';
import '../models/location_model.dart';

class HospitalMapWidget extends StatefulWidget {
  final LocationData hospitalLocation;
  final List<LocationData> facilities; // nearby facilities

  const HospitalMapWidget({
    super.key,
    required this.hospitalLocation,
    this.facilities = const [],
  });

  @override
  State<HospitalMapWidget> createState() => _HospitalMapWidgetState();
}

class _HospitalMapWidgetState extends State<HospitalMapWidget> {
  late GoogleMapController mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _addMarkers();
  }

  void _addMarkers() {
    // Add hospital marker
    _markers.add(
      Marker(
        markerId: MarkerId('hospital'),
        position: LatLng(
          widget.hospitalLocation.latitude,
          widget.hospitalLocation.longitude,
        ),
        infoWindow: InfoWindow(
          title: widget.hospitalLocation.name,
          snippet: widget.hospitalLocation.description,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );

    // Add facility markers
    for (int i = 0; i < widget.facilities.length; i++) {
      final facility = widget.facilities[i];
      _markers.add(
        Marker(
          markerId: MarkerId('facility_$i'),
          position: LatLng(facility.latitude, facility.longitude),
          infoWindow: InfoWindow(
            title: facility.name,
            snippet: facility.description,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Map
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 300,
            child: GoogleMap(
              onMapCreated: (controller) {
                mapController = controller;
                mapController.animateCamera(
                  CameraUpdate.newLatLngZoom(
                    LatLng(
                      widget.hospitalLocation.latitude,
                      widget.hospitalLocation.longitude,
                    ),
                    15,
                  ),
                );
              },
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  widget.hospitalLocation.latitude,
                  widget.hospitalLocation.longitude,
                ),
                zoom: 15,
              ),
              markers: _markers,
              polylines: _polylines,
              myLocationEnabled: false,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: true,
              scrollGesturesEnabled: true,
            ),
          ),
        ),

        const SizedBox(height: 16),
        // Info card
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.hospitalLocation.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (widget.hospitalLocation.address != null)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on,
                        color: customTheme[600],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.hospitalLocation.address!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }
}
