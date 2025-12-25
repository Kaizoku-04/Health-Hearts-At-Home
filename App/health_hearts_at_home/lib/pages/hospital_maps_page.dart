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
  LocationData? selectedLocation;
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
        latitude: 34.04944292612875,
        longitude: -117.26320484661548,
        name: 'Loma Linda University Children\'s Hospital',
        description: 'Main Hospital Location',
        address: '11234 Anderson St, Loma Linda, CA 92354, United States',
        phone: '+1 909-558-8000',
        website: 'https://lluch.org/',
      );

      // Example nearby facilities
      facilities = [
        LocationData(
          latitude: 34.049213175257684,
          longitude: -117.26533539527401,
          name: 'Charging Station',
          description: 'To charge electrical cars',
        ),
        LocationData(
          latitude: 34.05078027303055,
          longitude: -117.25936522742359,
          name: 'Loma Linda Market',
          description: '',
        ),
        LocationData(
          latitude: 34.049127951141244,
          longitude: -117.24238185816088,
          name: 'Angelo\'s restaurant',
          description: 'A kinda Healthy restaurant',
        ),
      ];

      setState(() {
        selectedLocation = hospitalLocation;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('Error loading location data: $e');
    }
  }

  void _selectLocation(LocationData location) {
    setState(() {
      selectedLocation = location;
    });
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
                  // Map with selected location
                  HospitalMapWidget(selectedLocation: selectedLocation!),
                  const SizedBox(height: 24),

                  // Location Selection Buttons
                  Text(
                    'Select Location',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: customTheme[700],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Hospital Button
                  ElevatedButton.icon(
                    onPressed: () => _selectLocation(hospitalLocation!),
                    icon: const Icon(Icons.local_hospital),
                    label: Text(hospitalLocation!.name),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedLocation == hospitalLocation
                          ? customTheme[500]
                          : Colors.grey[300],
                      foregroundColor: selectedLocation == hospitalLocation
                          ? Colors.white
                          : Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Facilities Buttons
                  ...facilities.map((facility) {
                    final isSelected = selectedLocation == facility;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ElevatedButton.icon(
                        onPressed: () => _selectLocation(facility),
                        icon: const Icon(Icons.location_on),
                        label: Text(facility.name),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSelected
                              ? customTheme[500]
                              : Colors.grey[300],
                          foregroundColor: isSelected
                              ? Colors.white
                              : Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }
}
