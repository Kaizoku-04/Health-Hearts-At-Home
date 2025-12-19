import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_service.dart';
import '../services/localization_service.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/hospital_map_widget.dart';
import '../models/location_model.dart';
import '../models/themes.dart';

class HospitalMapsPage extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const HospitalMapsPage({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  State<HospitalMapsPage> createState() => _HospitalMapsPageState();
}

class _HospitalMapsPageState extends State<HospitalMapsPage> {
  LocationData? hospitalLocation;
  List<LocationData> facilities = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLocationData();
  }

  Future<void> _loadLocationData() async {
    try {
      // Example location data - Replace with actual API call
      hospitalLocation = LocationData(
        latitude: 37.4419,
        longitude: -122.1430,
        name: 'X University Hospital',
        description: 'Main Hospital Location',
        address: '123 Medical Center Blvd, City, State 12345',
        phone: '+1 (XXX) XXX-XXXX',
        website: 'https://xuhosp.com',
      );

      // Example nearby facilities
      facilities = [
        LocationData(
          latitude: 37.4420,
          longitude: -122.1432,
          name: 'Parking Lot A',
          description: 'Visitor Parking',
        ),
        LocationData(
          latitude: 37.4417,
          longitude: -122.1428,
          name: 'Cafeteria',
          description: 'Hospital Cafeteria',
        ),
        LocationData(
          latitude: 37.4421,
          longitude: -122.1425,
          name: 'Emergency Entrance',
          description: 'Emergency Room',
        ),
      ];

      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('Error loading location data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final appService = context.watch<AppService>();
    final lang = appService.currentLanguage;

    return Scaffold(
      appBar: CHDAppBar(
        title: AppStrings.get('hospitalMap', lang),
        onToggleTheme: widget.onToggleTheme,
        isDark: widget.isDark,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hospitalLocation == null
          ? Center(child: Text(AppStrings.get('errorLoading', lang)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  HospitalMapWidget(
                    hospitalLocation: hospitalLocation!,
                    facilities: facilities,
                  ),
                  const SizedBox(height: 24),
                  // Nearby Facilities
                  Text(
                    'Nearby Facilities',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: customTheme[700],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...facilities.map((facility) {
                    return Card(
                      elevation: 1,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(
                          Icons.location_on,
                          color: customTheme[600],
                        ),
                        title: Text(facility.name),
                        subtitle: Text(facility.description),
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }
}
