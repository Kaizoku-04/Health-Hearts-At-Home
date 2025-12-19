import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_service.dart';
import '../services/localization_service.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/tracking_input_widget.dart';
import '../models/themes.dart';

class TrackChildPage extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const TrackChildPage({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  State<TrackChildPage> createState() => _TrackChildPageState();
}

class _TrackChildPageState extends State<TrackChildPage> {
  final List<Map<String, dynamic>> _trackingHistory = [];
  bool _showForm = false;

  @override
  Widget build(BuildContext context) {
    final appService = context.watch<AppService>();
    final lang = appService.currentLanguage;

    return Scaffold(
      appBar: CHDAppBar(
        title: AppStrings.get('trackChild', lang),
        onToggleTheme: widget.onToggleTheme,
        isDark: widget.isDark,
      ),
      body: _showForm
          ? TrackingInputWidget(language: lang, onSave: _addTrackingEntry)
          : _buildHistoryView(lang),
      floatingActionButton: FloatingActionButton(
        backgroundColor: customTheme[500],
        onPressed: () => setState(() => _showForm = !_showForm),
        child: Icon(_showForm ? Icons.close : Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHistoryView(String lang) {
    return _trackingHistory.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  AppStrings.get('noData', lang),
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          )
        : ListView.builder(
            itemCount: _trackingHistory.length,
            itemBuilder: (context, index) {
              final entry = _trackingHistory[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry['date'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (entry['weight'].isNotEmpty)
                        Text(
                          '${AppStrings.get('weight', lang)}: ${entry['weight']} kg',
                        ),
                      if (entry['feedingAmount'].isNotEmpty)
                        Text(
                          '${AppStrings.get('feedingAmount', lang)}: ${entry['feedingAmount']} ml',
                        ),
                      if (entry['oxygenSaturation'].isNotEmpty)
                        Text(
                          '${AppStrings.get('oxygenSaturation', lang)}: ${entry['oxygenSaturation']}%',
                        ),
                    ],
                  ),
                ),
              );
            },
          );
  }

  void _addTrackingEntry(Map<String, dynamic> entry) {
    setState(() {
      _trackingHistory.insert(0, entry);
      _showForm = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppStrings.get('save', context.read<AppService>().currentLanguage),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
