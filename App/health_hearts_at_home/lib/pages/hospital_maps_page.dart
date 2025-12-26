import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_service.dart';
import '../services/localization_service.dart';
import '../widgets/hospital_map_widget.dart';
import '../models/location_model.dart';

class HospitalMapsPage extends StatefulWidget {
  final bool isDark; // Kept for consistency, but we check theme dynamically
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
      // Example location data
      hospitalLocation = LocationData(
        latitude: 34.04944292612875,
        longitude: -117.26320484661548,
        name: 'Loma Linda University Children\'s Hospital',
        description: 'Main Hospital Location',
        address: '11234 Anderson St, Loma Linda, CA 92354, United States',
        phone: '+1 909-558-8000',
        website: 'https://lluch.org/',
      );

      facilities = [
        LocationData(
          latitude: 34.049213175257684,
          longitude: -117.26533539527401,
          name: 'Charging Station',
          description: 'Electric vehicle charging',
          address: '',
          phone: '',
          website: '',
        ),
        LocationData(
          latitude: 34.05078027303055,
          longitude: -117.25936522742359,
          name: 'Loma Linda Market',
          description: 'Groceries & supplies',
          address: '',
          phone: '',
          website: '',
        ),
        LocationData(
          latitude: 34.049127951141244,
          longitude: -117.24238185816088,
          name: 'Angelo\'s Restaurant',
          description: 'Healthy dining options',
          address: '',
          phone: '',
          website: '',
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

    // --- DYNAMIC THEME CHECK ---
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // --- NEUTRAL PLATINUM PALETTE ---
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFE7E7EC);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final primaryText = isDark ? Colors.white : const Color(0xFF1D1D1F);
    final secondaryText = isDark ? Colors.grey[400]! : const Color(0xFF5A5A60);
    const accentColor = Color(0xFF264653); // Hospital Teal

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: primaryText, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppStrings.get('hospitalMap', lang),
          style: TextStyle(
            color: primaryText,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          // --- LANGUAGE TOGGLE ---
          IconButton(
            icon: const Icon(Icons.language),
            color: primaryText,
            tooltip: 'Change Language',
            onPressed: () {
              final newLang = lang == 'en' ? 'ar' : 'en';
              appService.setLanguage(newLang);
            },
          ),
          // --- THEME TOGGLE ---
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: primaryText,
            ),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: accentColor))
          : hospitalLocation == null
          ? Center(child: Text(AppStrings.get('errorLoading', lang), style: TextStyle(color: secondaryText)))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- MAP CONTAINER ---
            Container(
              height: 450, // Fixed height for consistency
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              // ClipRRect ensures the map corners respect the container radius
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: HospitalMapWidget(selectedLocation: selectedLocation!),
              ),
            ),
            const SizedBox(height: 28),

            // --- SELECTION HEADER ---
            Text(
              'Select Destination',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: secondaryText,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),

            // --- HOSPITAL BUTTON ---
            _buildLocationButton(
              location: hospitalLocation!,
              isSelected: selectedLocation == hospitalLocation,
              icon: Icons.local_hospital_rounded,
              accentColor: accentColor,
              cardColor: cardColor,
              primaryText: primaryText,
              secondaryText: secondaryText,
              isDark: isDark,
            ),
            const SizedBox(height: 12),

            // --- FACILITIES BUTTONS ---
            ...facilities.map((facility) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildLocationButton(
                  location: facility,
                  isSelected: selectedLocation == facility,
                  icon: Icons.place_rounded, // Generic pin for others
                  accentColor: accentColor,
                  cardColor: cardColor,
                  primaryText: primaryText,
                  secondaryText: secondaryText,
                  isDark: isDark,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // --- HELPER: SOPHISTICATED SELECTION BUTTON ---
  Widget _buildLocationButton({
    required LocationData location,
    required bool isSelected,
    required IconData icon,
    required Color accentColor,
    required Color cardColor,
    required Color primaryText,
    required Color secondaryText,
    required bool isDark,
  }) {
    // If selected, use Accent Color background + White Text
    // If not selected, use Card Color background + Normal Text
    final backgroundColor = isSelected ? accentColor : cardColor;
    final titleColor = isSelected ? Colors.white : primaryText;
    final subtitleColor = isSelected ? Colors.white.withOpacity(0.8) : secondaryText;
    final iconColor = isSelected ? Colors.white : accentColor;

    return GestureDetector(
      onTap: () => _selectLocation(location),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? null // No border if selected (color fill is enough)
              : Border.all(color: Colors.grey.withOpacity(isDark ? 0.2 : 0.1), width: 1),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? accentColor.withOpacity(0.4) // Colored shadow if selected
                  : Colors.black.withOpacity(isDark ? 0.0 : 0.03),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.2) : accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                  ),
                  if (location.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      location.description,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: subtitleColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Checkmark if selected
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.check_circle, color: Colors.white, size: 20),
              ),
          ],
        ),
      ),
    );
  }
}
