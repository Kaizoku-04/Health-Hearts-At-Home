// lib/pages/track_child_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_service.dart';
import '../services/localization_service.dart';
import '../widgets/tracking_input_widget.dart';
import '../models/child_model.dart';
import '../models/tracking_model.dart';

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
  List<Child> _children = [];
  String? _selectedChildId;
  bool _isLoadingChildren = false;
  bool _isLoadingTracking = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // fetch children when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChildren();
    });
  }

  Future<void> _loadChildren() async {
    setState(() {
      _isLoadingChildren = true;
    });

    final appService = context.read<AppService>();

    try {
      // AppService.fetchChildren returns List<Child>
      final List<Child> children = await appService.fetchChildren();
      setState(() {
        _children = children;
        // default select first child if present
        if (_children.isNotEmpty) {
          _selectedChildId = _children[0].id;
        }
      });

      // If we selected a child, load its tracking data
      if (_selectedChildId != null) {
        await _loadTrackingForChild(_selectedChildId!);
      }
    } finally {
      setState(() {
        _isLoadingChildren = false;
      });
    }
  }

  Future<void> _loadTrackingForChild(String childId) async {
    setState(() {
      _isLoadingTracking = true;
    });

    final appService = context.read<AppService>();

    try {
      // This triggers the service to populate its internal _trackingData
      await appService.fetchTrackingData(childId);

      // After the service fetched data, read it from the service.
      // I assume AppService exposes a getter `trackingData` which returns List<ChildTracking>.
      final List<ChildTracking> serverData = appService.trackingData;

      // Convert to the structure the UI expects (Map<String,dynamic>) or keep objects
      setState(() {
        _trackingHistory.clear();
        for (final t in serverData) {
          _trackingHistory.add({
            'id': t.id,
            'childId': t.childId,
            'date': t.recordedAt, // for display
            'weight': t.weight?.toString() ?? '',
            'feedingAmount': t.feedingAmount?.toString() ?? '',
            'feedingType': t.feedingType ?? '',
            'oxygenSaturation': t.oxygenSaturation?.toString() ?? '',
            'equipment': t.equipment ?? '',
            'notes': t.note ?? '', // note → notes for UI
          });
        }
      });
    } finally {
      setState(() {
        _isLoadingTracking = false;
      });
    }
  }

  // Called by TrackingInputWidget when saving a new record
  Future<void> _addTrackingEntry(Map<String, dynamic> entryMap) async {
    if (_selectedChildId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Select a child first')));
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final appService = context.read<AppService>();

    try {
      // Build a ChildTracking model to send to service
      final newEntry = ChildTracking(
        id: entryMap['id'] ?? '',
        childId: _selectedChildId!,
        recordedAt: entryMap['date'], // date from form → recordedAt for backend
        weight: entryMap['weight'] != ''
            ? double.tryParse(entryMap['weight'])
            : null,
        note: entryMap['notes'], // notes from form → note
        feedingAmount: entryMap['feedingAmount'] != ''
            ? int.tryParse(entryMap['feedingAmount'])
            : null,
        feedingType: entryMap['feedingType'],
        oxygenSaturation: entryMap['oxygenSaturation'] != ''
            ? double.tryParse(entryMap['oxygenSaturation'])
            : null,
        equipment: entryMap['equipment'],
      );

      final ok = await appService.addTrackingEntry(newEntry);

      if (ok == true) {
        // Refresh from server to get canonical data (including server-generated id)
        await _loadTrackingForChild(_selectedChildId!);
        _showSnack(
          AppStrings.get('saved', context.read<AppService>().currentLanguage),
        );
      } else {
        _showSnack('Failed to save entry');
      }
    } catch (e) {
      _showSnack('Error: $e');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _updateTrackingEntry(Map<String, dynamic> entryMap) async {
    if (entryMap['id'] == null) return;
    setState(() {
      _isSaving = true;
    });

    final appService = context.read<AppService>();

    try {
      final entry = ChildTracking(
        id: entryMap['id'],
        childId: entryMap['childId'],
        recordedAt: entryMap['recordedAt'],
        weight: entryMap['weight'] != ''
            ? double.tryParse(entryMap['weight'])
            : null,
        feedingAmount: entryMap['feedingAmount'] != ''
            ? int.tryParse(entryMap['feedingAmount'])
            : null,
        feedingType: entryMap['feedingType'],
        oxygenSaturation: entryMap['oxygenSaturation'] != ''
            ? double.tryParse(entryMap['oxygenSaturation'])
            : null,
        equipment: entryMap['equipment'],
        note: entryMap['note'],
      );

      final ok = await appService.updateTrackingEntry(entry);

      if (ok == true) {
        await _loadTrackingForChild(_selectedChildId!);
        _showSnack(
          AppStrings.get('updated', context.read<AppService>().currentLanguage),
        );
      } else {
        _showSnack('Failed to update entry');
      }
    } catch (e) {
      _showSnack('Error: $e');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _deleteTrackingEntry(String entryId) async {
    setState(() {
      _isSaving = true;
    });

    final appService = context.read<AppService>();

    try {
      final ok = await appService.deleteTrackingEntry(entryId);
      if (ok == true) {
        // remove locally for instant feedback
        setState(() {
          _trackingHistory.removeWhere((t) => t['id'] == entryId);
        });
        _showSnack(
          AppStrings.get('deleted', context.read<AppService>().currentLanguage),
        );
      } else {
        _showSnack('Failed to delete entry');
      }
    } catch (e) {
      _showSnack('Error: $e');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _showSnack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Widget _buildChildSelector() {
    if (_isLoadingChildren) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_children.isEmpty) {
      return Text(
        AppStrings.get(
          'noChildren',
          context.read<AppService>().currentLanguage,
        ),
      );
    }

    return DropdownButton<String>(
      value: _selectedChildId,
      items: _children
          .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
          .toList(),
      onChanged: (value) async {
        setState(() {
          _selectedChildId = value;
        });
        if (value != null) await _loadTrackingForChild(value);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final lang = context.read<AppService>().currentLanguage;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('trackChild', lang)),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isSaving
            ? null
            : () {
                // open the input widget for adding a new entry
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => TrackingInputWidget(
                    language: lang,
                    onSave: (map) {
                      map['childId'] = _selectedChildId;
                      _addTrackingEntry(map);
                    },
                  ),
                );
              },
        child: _isSaving
            ? const CircularProgressIndicator()
            : const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // child selector
            Align(
              alignment: Alignment.centerLeft,
              child: _buildChildSelector(),
            ),
            const SizedBox(height: 12),

            if (_isLoadingTracking)
              const Center(child: CircularProgressIndicator())
            else if (_trackingHistory.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.hourglass_empty,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 12),
                      Text(AppStrings.get('noData', lang)),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.get('tapAdd', lang),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: _trackingHistory.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final entry = _trackingHistory[index];
                    return Card(
                      child: ListTile(
                        title: Text(entry['date'] ?? ''),
                        subtitle: Text(entry['notes'] ?? ''),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                // open input to edit; pass current entry and use onSave to update
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (_) => TrackingInputWidget(
                                    language: lang,
                                    onSave: (map) {
                                      map['childId'] = _selectedChildId;
                                      _updateTrackingEntry(map);
                                    },
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (c) => AlertDialog(
                                    title: Text(
                                      AppStrings.get('confirm', lang),
                                    ),
                                    content: Text(
                                      AppStrings.get('confirmDelete', lang),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(c, false),
                                        child: Text(AppStrings.get('no', lang)),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(c, true),
                                        child: Text(
                                          AppStrings.get('yes', lang),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await _deleteTrackingEntry(entry['id']);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
