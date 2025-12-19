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
  Map<String, dynamic>? hospitalInfo;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHospitalInfo();
  }

  Future<void> _loadHospitalInfo() async {
    try {
      final appService = context.read<AppService>();
      final info = await appService.fetchHospitalInfo();
      setState(() {
        hospitalInfo = info;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('Error loading hospital info: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final appService = context.watch<AppService>();
    final lang = appService.currentLanguage;

    return Scaffold(
      appBar: CHDAppBar(
        title: AppStrings.get('hospitalInfo', lang),
        onToggleTheme: widget.onToggleTheme,
        isDark: widget.isDark,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildInfoCard(
                    title: AppStrings.get('hospitalName', lang),
                    content: hospitalInfo?['name'] ?? 'X University Hospital',
                    icon: Icons.local_hospital,
                  ),
                  const SizedBox(height: 16),
                  _buildContactCard(
                    title: AppStrings.get('hospitalPhone', lang),
                    content: hospitalInfo?['phone'] ?? '+1 (XXX) XXX-XXXX',
                    icon: Icons.phone,
                    onTap: () {
                      URLLauncherService.makePhoneCall(
                        hospitalInfo?['phone'] ?? '',
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildContactCard(
                    title: AppStrings.get('hospitalEmail', lang),
                    content: hospitalInfo?['email'] ?? 'info@xuhosp.com',
                    icon: Icons.email,
                    onTap: () {
                      URLLauncherService.sendEmail(
                        email: hospitalInfo?['email'] ?? '',
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    title: AppStrings.get('cafeteriaHours', lang),
                    content: hospitalInfo?['cafeteriaHours'] ?? '6AM - 8PM',
                    icon: Icons.restaurant,
                  ),
                  const SizedBox(height: 16),
                  _buildContactCard(
                    title: AppStrings.get('hospitalWebsite', lang),
                    content: hospitalInfo?['website'] ?? 'www.xuhosp.com',
                    icon: Icons.language,
                    onTap: () {
                      URLLauncherService.openWebsite(
                        hospitalInfo?['website'] ?? '',
                      );
                    },
                  ),
                  // Inside _buildContactCard or add a new button:
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: customTheme[500],
                      padding: const EdgeInsets.symmetric(vertical: 12),
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
                    icon: const Icon(Icons.map, color: Colors.white),
                    label: const Text(
                      'View Hospital Map',
                      style: TextStyle(color: Colors.white),
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
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: customTheme[600], size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: customTheme[600]),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              content,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: Icon(Icons.arrow_forward, color: customTheme[500]),
        onTap: onTap,
      ),
    );
  }
}
