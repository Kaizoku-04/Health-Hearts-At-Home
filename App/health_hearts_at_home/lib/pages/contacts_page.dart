import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_service.dart';
import '../services/localization_service.dart';
import '../services/url_launcher_service.dart';

class ContactsPage extends StatefulWidget {
  final bool isDark; // Kept for consistency, but checking dynamically
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
  // Removed isLoading for a snappier, instant UI

  @override
  Widget build(BuildContext context) {
    final appService = context.watch<AppService>();
    final lang = appService.currentLanguage;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F7);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final primaryText = isDark ? Colors.white : const Color(0xFF1D1D1F);
    final secondaryText = isDark ? const Color(0xFFBDBDBD) : const Color(0xFF5A5A60);

    // This variable is now used below in _buildSectionHeader
    const accentColor = Color(0xFF2A9D8F);

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
          AppStrings.get('contacts', lang),
          style: TextStyle(
            color: primaryText,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            color: primaryText,
            tooltip: 'Change Language',
            onPressed: () {
              final newLang = lang == 'en' ? 'ar' : 'en';
              appService.setLanguage(newLang);
            },
          ),
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: primaryText,
            ),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SECTION 1: GET IN TOUCH ---
            // FIXED: Using accentColor here removes the warning and styles the text
            _buildSectionHeader("GET IN TOUCH", accentColor),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.withOpacity(isDark ? 0.2 : 0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.0 : 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildContactTile(
                    label: '+1 909-558-8000',
                    subLabel: "Hospital Main Line",
                    icon: Icons.phone_rounded,
                    iconColor: Colors.green,
                    primaryText: primaryText,
                    secondaryText: secondaryText,
                    onTap: () async {
                      final success = await URLLauncherService.makePhoneCall('+1 909-558-8000');
                      if (!success && mounted) _showError(context, 'Could not make call');
                    },
                  ),
                  _buildDivider(isDark),
                  _buildContactTile(
                    label: 'info@xuhosp.com',
                    subLabel: "General Inquiries",
                    icon: Icons.email_rounded,
                    iconColor: Colors.blue,
                    primaryText: primaryText,
                    secondaryText: secondaryText,
                    onTap: () async {
                      final success = await URLLauncherService.sendEmail(
                        email: 'info@xuhosp.com',
                        subject: 'Inquiry from CHD App',
                      );
                      if (!success && mounted) _showError(context, 'Could not send email');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // --- SECTION 2: SOCIAL MEDIA ---
            // FIXED: Using accentColor here too
            _buildSectionHeader("FOLLOW US", accentColor),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.withOpacity(isDark ? 0.2 : 0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.0 : 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildContactTile(
                    label: 'Instagram',
                    subLabel: "@LLUChildrens",
                    assetPath: 'lib/assets/instagram.png',
                    primaryText: primaryText,
                    secondaryText: secondaryText,
                    onTap: () async {
                      final success = await URLLauncherService.openInstagram(username: 'LLUChildrens');
                      if (!success && mounted) _showError(context, 'Could not open Instagram');
                    },
                  ),
                  _buildDivider(isDark),
                  _buildContactTile(
                    label: 'Facebook',
                    subLabel: "/LLUChildrens",
                    assetPath: 'lib/assets/facebook.png',
                    primaryText: primaryText,
                    secondaryText: secondaryText,
                    onTap: () async {
                      final success = await URLLauncherService.openFacebook(pagePath: 'LLUChildrens');
                      if (!success && mounted) _showError(context, 'Could not open Facebook');
                    },
                  ),
                  _buildDivider(isDark),
                  _buildContactTile(
                    label: 'YouTube',
                    subLabel: "@LLUChildrens",
                    assetPath: 'lib/assets/youtube.png',
                    primaryText: primaryText,
                    secondaryText: secondaryText,
                    onTap: () async {
                      final success = await URLLauncherService.openYouTube(url: 'https://www.youtube.com/@LLUHealth');
                      if (!success && mounted) _showError(context, 'Could not open YouTube');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      indent: 60, // Starts after the icon
      color: Colors.grey.withOpacity(isDark ? 0.2 : 0.1),
    );
  }

  Widget _buildContactTile({
    required String label,
    String? subLabel,
    IconData? icon,
    String? assetPath,
    Color? iconColor,
    required Color primaryText,
    required Color secondaryText,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              // --- Leading Icon/Image ---
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: (iconColor ?? Colors.grey).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: assetPath != null
                    ? Image.asset(assetPath, width: 24, height: 24, errorBuilder: (c, o, s) => const Icon(Icons.link, size: 20))
                    : Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 16),

              // --- Text ---
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: primaryText,
                      ),
                    ),
                    if (subLabel != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subLabel,
                        style: TextStyle(
                          fontSize: 13,
                          color: secondaryText,
                        ),
                      ),
                    ]
                  ],
                ),
              ),

              // --- Trailing Arrow ---
              Icon(Icons.chevron_right, color: Colors.grey.withOpacity(0.4), size: 22),
            ],
          ),
        ),
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}