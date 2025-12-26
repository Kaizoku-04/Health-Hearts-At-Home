import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/themes.dart';
import '../models/location_model.dart';

class HospitalMapWidget extends StatefulWidget {
  final LocationData selectedLocation;

  const HospitalMapWidget({super.key, required this.selectedLocation});

  @override
  State<HospitalMapWidget> createState() => _HospitalMapWidgetState();
}

class _HospitalMapWidgetState extends State<HospitalMapWidget> {
   GoogleMapController? mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final secrets = dotenv.load(fileName: ".env");

  @override
  void initState() {
    super.initState();
    _addMarkers();
  }

  @override
  void didUpdateWidget(HospitalMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedLocation != widget.selectedLocation) {
      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(
            widget.selectedLocation.latitude,
            widget.selectedLocation.longitude,
          ),
          17,
        ),
      );
    }
  }

  void _addMarkers() {
    _markers.clear();

    // Add hospital marker (always)
    _markers.add(
      Marker(
        markerId: const MarkerId('hospital'),
        position: LatLng(
          widget.selectedLocation.latitude,
          widget.selectedLocation.longitude,
        ),
        infoWindow: InfoWindow(
          title: widget.selectedLocation.name,
          snippet: widget.selectedLocation.description,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );
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
              },
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  widget.selectedLocation.latitude,
                  widget.selectedLocation.longitude,
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
                  widget.selectedLocation.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (widget.selectedLocation.address != null)
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
                          widget.selectedLocation.address!,
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
    mapController?.dispose();
    super.dispose();
  }
}
