import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_service.dart';
import '../services/localization_service.dart';
import '../services/url_launcher_service.dart';
import '../widgets/app_bar_widget.dart';
import '../models/themes.dart';

class ContactsPage extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const ContactsPage({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
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
        title: AppStrings.get('contacts', lang),
        onToggleTheme: widget.onToggleTheme,
        isDark: widget.isDark,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Phone
                        _buildContactButton(
                          icon: Icons.phone,
                          label: '+1 909-558-8000',
                          onPressed: () async {
                            final success =
                                await URLLauncherService.makePhoneCall(
                                  '+1 909-558-8000',
                                );
                            if (!success && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Could not make call'),
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 8),

                        // Email
                        _buildContactButton(
                          icon: Icons.email,
                          label: 'info@xuhosp.com',
                          onPressed: () async {
                            final success = await URLLauncherService.sendEmail(
                              email: 'info@xuhosp.com',
                              subject: 'Inquiry from CHD App',
                            );
                            if (!success && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Could not send email'),
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 8),

                        // Instagram
                        _buildImageContactButton(
                          assetPath: 'lib/assets/instagram.png',
                          label: 'Instagram @LLUChildrens',
                          onPressed: () async {
                            final success =
                                await URLLauncherService.openInstagram(
                                  username: 'LLUChildrens',
                                );
                            if (!success && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Could not open Instagram'),
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 8),

                        // Facebook
                        _buildImageContactButton(
                          assetPath: 'lib/assets/facebook.png',
                          label: 'Facebook /LLUChildrens',
                          onPressed: () async {
                            final success =
                                await URLLauncherService.openFacebook(
                                  pagePath: 'LLUChildrens',
                                );
                            if (!success && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Could not open Facebook'),
                                ),
                              );
                            }
                          },
                        ),

                        // YouTube
                        _buildImageContactButton(
                          assetPath: 'lib/assets/youtube.png',
                          label: 'YouTube @LLUChildrens',
                          onPressed: () async {
                            final success =
                                await URLLauncherService.openYouTube(
                                  url: 'https://www.youtube.com/@LLUHealth',
                                );
                            if (!success && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Could not open YouTube'),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildContactButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: customTheme[600]),
      title: Text(
        label,
        style: const TextStyle(fontSize: 14),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Icon(Icons.arrow_forward, color: customTheme[500], size: 18),
      onTap: onPressed,
    );
  }

  Widget _buildImageContactButton({
    required String assetPath,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ListTile(
      dense: true,
      leading: Image.asset(assetPath, width: 24, height: 24),
      title: Text(
        label,
        style: const TextStyle(fontSize: 14),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Icon(Icons.arrow_forward, color: customTheme[500], size: 18),
      onTap: onPressed,
    );
  }
}
