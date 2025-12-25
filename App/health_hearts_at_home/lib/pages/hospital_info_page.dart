import 'package:flutter/material.dart';
import 'package:health_hearts_at_home/pages/hospital_maps_page.dart';
import 'package:provider/provider.dart';
import '../models/themes.dart';
import '../services/app_service.dart';
import '../services/localization_service.dart';
import '../services/url_launcher_service.dart';
import '../widgets/app_bar_widget.dart';

class HospitalInfoPage extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const HospitalInfoPage({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  State<HospitalInfoPage> createState() => _HospitalInfoPageState();
}

class _HospitalInfoPageState extends State<HospitalInfoPage> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final appService = context.watch<AppService>();
    final lang = appService.currentLanguage;

    return Scaffold(
      appBar: CHDAppBar(
        title: "Hospital Information",
        onToggleTheme: widget.onToggleTheme,
        isDark: widget.isDark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hospital Name Card
            _buildInfoCard(
              title: AppStrings.get('hospitalName', lang),
              content: 'Loma Linda University Children\'s Hospital',
              icon: Icons.local_hospital,
            ),
            const SizedBox(height: 16),
            // Cafeteria Hours Card
            _buildInfoCard(
              title: AppStrings.get('cafeteriaHours', lang),
              content: '6AM - 8PM',
              icon: Icons.restaurant,
            ),
            const SizedBox(height: 16),

            // Website Card
            _buildContactCard(
              title: AppStrings.get('hospitalWebsite', lang),
              content: 'https://lluch.org/',
              icon: Icons.language,
              onTap: () {
                URLLauncherService.openWebsite('https://lluch.org/');
              },
            ),
            const SizedBox(height: 28),

            // Website Card
            _buildContactCard(
              title: AppStrings.get('Heart Care Service Website', lang),
              content: 'https://lluch.org/heart-care',
              icon: Icons.monitor_heart,
              onTap: () {
                URLLauncherService.openWebsite('https://lluch.org/heart-care');
              },
            ),
            const SizedBox(height: 28),

            // Website Card
            _buildContactCard(
              title: AppStrings.get('Children\'s emergency room website', lang),
              content: 'https://lluch.org/services/childrens-emergency-room',
              icon: Icons.bedroom_child,
              onTap: () {
                URLLauncherService.openWebsite(
                  'https://lluch.org/services/childrens-emergency-room',
                );
              },
            ),
            const SizedBox(height: 28),

            // Website Card
            _buildContactCard(
              title: AppStrings.get('Children\'s emergency room website', lang),
              content:
                  'https://lluch.org/patients-families/patients/billing-insurance',
              icon: Icons.bedroom_child,
              onTap: () {
                URLLauncherService.openWebsite(
                  'https://lluch.org/patients-families/patients/billing-insurance',
                );
              },
            ),
            const SizedBox(height: 28),

            // Map Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: customTheme[500],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HospitalMapsPage(
                      isDark: widget.isDark,
                      onToggleTheme: widget.onToggleTheme,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.map, size: 22),
              label: const Text(
                'View Hospital Map',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Card(
      elevation: 3,
      shadowColor: customTheme[500]?.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon container with background
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: customTheme[500]?.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: customTheme[600], size: 28),
            ),
            const SizedBox(width: 16),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    content,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[900],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required String title,
    required String content,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shadowColor: customTheme[500]?.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: customTheme[500]?.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Icon container
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: customTheme[500]?.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: customTheme[600], size: 24),
              ),
              const SizedBox(width: 16),

              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      content,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[900],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Arrow icon
              Icon(Icons.arrow_forward_ios, color: customTheme[500], size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
