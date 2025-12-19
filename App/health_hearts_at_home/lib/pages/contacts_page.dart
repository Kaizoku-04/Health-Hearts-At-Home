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
  List<Map<String, dynamic>> contacts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    try {
      final appService = context.read<AppService>();
      final loadedContacts = await appService.fetchContacts();
      setState(() {
        contacts = loadedContacts;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('Error loading contacts: $e');
    }
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
          : contacts.isEmpty
          ? Center(child: Text(AppStrings.get('noData', lang)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                final name = contact['name'] ?? 'Unknown';
                final phone = contact['phone'];
                final email = contact['email'];

                return Card(
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
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Phone button
                        if (phone != null)
                          _buildContactButton(
                            icon: Icons.phone,
                            label: phone,
                            onPressed: () async {
                              final success =
                                  await URLLauncherService.makePhoneCall(phone);
                              if (!success && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Could not make call'),
                                  ),
                                );
                              }
                            },
                          ),
                        if (phone != null && email != null)
                          const SizedBox(height: 8),
                        // Email button
                        if (email != null)
                          _buildContactButton(
                            icon: Icons.email,
                            label: email,
                            onPressed: () async {
                              final success =
                                  await URLLauncherService.sendEmail(
                                    email: email,
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
                      ],
                    ),
                  ),
                );
              },
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
}
