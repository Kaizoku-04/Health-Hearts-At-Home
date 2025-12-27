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
  // --- BACKEND STATE VARIABLES ---
  final List<Map<String, dynamic>> _trackingHistory = [];
  List<Child> _children = [];
  String? _selectedChildId;
  bool _isLoadingChildren = false;
  bool _isLoadingTracking = false;
  bool _isSaving = false;

  // --- THEME CONSTANTS ---
  static const Color accentColor = Color(0xFF3A1C71); // Royal Purple

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChildren();
    });
  }

  // --- BACKEND METHODS ---

  Future<void> _loadChildren() async {
    setState(() => _isLoadingChildren = true);
    final appService = context.read<AppService>();
    try {
      final List<Child> children = await appService.fetchChildren();
      setState(() {
        _children = children;
        // Default to first child if selection is empty
        if (_selectedChildId == null && _children.isNotEmpty) {
          _selectedChildId = _children[0].id;
        }
      });
      if (_selectedChildId != null) {
        await _loadTrackingForChild(_selectedChildId!);
      }
    } finally {
      setState(() => _isLoadingChildren = false);
    }
  }

  Future<void> _loadTrackingForChild(String childId) async {
    setState(() => _isLoadingTracking = true);
    final appService = context.read<AppService>();
    try {
      await appService.fetchTrackingData(childId);
      final List<ChildTracking> serverData = appService.trackingData;

      setState(() {
        _trackingHistory.clear();
        for (final t in serverData) {
          _trackingHistory.add({
            'id': t.id,
            'childId': t.childId,
            'date': t.recordedAt,
            'weight': t.weight?.toString() ?? '',
            'feedingAmount': t.feedingAmount?.toString() ?? '',
            'feedingType': t.feedingType ?? '',
            'oxygenSaturation': t.oxygenSaturation?.toString() ?? '',
            'equipment': t.equipment ?? '',
            'notes': t.note ?? '',
          });
        }
      });
    } finally {
      setState(() => _isLoadingTracking = false);
    }
  }

  // ✅ NEW: Local Logic to Add Child (UI Only)
  void _addLocalChild(String name) {
    if (name.trim().isEmpty) return;

    Navigator.pop(context); // Close dialog

    // Create a temporary child for the UI
    final newChild = Child(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name, dateOfBirth: ''
    );

    setState(() {
      _children.add(newChild); // Add to local list
      _selectedChildId = newChild.id; // Auto-select it
      _trackingHistory.clear(); // Clear history for new child
    });

    _showSnack("Child '$name' added locally (UI Only)");
  }

  Future<void> _addTrackingEntry(Map<String, dynamic> entryMap) async {
    if (_selectedChildId == null) {
      _showSnack('Select a child first');
      return;
    }
    setState(() => _isSaving = true);
    final appService = context.read<AppService>();

    try {
      final newEntry = ChildTracking(
        id: entryMap['id'] ?? '',
        childId: _selectedChildId!,
        recordedAt: entryMap['date'],
        weight: entryMap['weight'] != '' ? double.tryParse(entryMap['weight']) : null,
        note: entryMap['notes'],
        feedingAmount: entryMap['feedingAmount'] != '' ? int.tryParse(entryMap['feedingAmount']) : null,
        feedingType: entryMap['feedingType'],
        oxygenSaturation: entryMap['oxygenSaturation'] != '' ? double.tryParse(entryMap['oxygenSaturation']) : null,
        equipment: entryMap['equipment'],
      );

      final ok = await appService.addTrackingEntry(newEntry);
      if (ok == true) {
        await _loadTrackingForChild(_selectedChildId!);
        _showSnack(AppStrings.get('saved', context.read<AppService>().currentLanguage));
      } else {
        _showSnack('Failed to save entry');
      }
    } catch (e) {
      _showSnack('Error: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _updateTrackingEntry(Map<String, dynamic> entryMap) async {
    if (entryMap['id'] == null) return;
    setState(() => _isSaving = true);
    final appService = context.read<AppService>();

    try {
      final entry = ChildTracking(
        id: entryMap['id'],
        childId: entryMap['childId'],
        recordedAt: entryMap['recordedAt'],
        weight: entryMap['weight'] != '' ? double.tryParse(entryMap['weight']) : null,
        feedingAmount: entryMap['feedingAmount'] != '' ? int.tryParse(entryMap['feedingAmount']) : null,
        feedingType: entryMap['feedingType'],
        oxygenSaturation: entryMap['oxygenSaturation'] != '' ? double.tryParse(entryMap['oxygenSaturation']) : null,
        equipment: entryMap['equipment'],
        note: entryMap['notes'],
      );

      final ok = await appService.updateTrackingEntry(entry);
      if (ok == true) {
        await _loadTrackingForChild(_selectedChildId!);
        _showSnack(AppStrings.get('updated', context.read<AppService>().currentLanguage));
      } else {
        _showSnack('Failed to update entry');
      }
    } catch (e) {
      _showSnack('Error: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteTrackingEntry(String entryId) async {
    setState(() => _isSaving = true);
    final appService = context.read<AppService>();
    try {
      final ok = await appService.deleteTrackingEntry(entryId);
      if (ok == true) {
        setState(() {
          _trackingHistory.removeWhere((t) => t['id'] == entryId);
        });
        _showSnack(AppStrings.get('deleted', context.read<AppService>().currentLanguage));
      } else {
        _showSnack('Failed to delete entry');
      }
    } catch (e) {
      _showSnack('Error: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showSnack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  // --- POPUP DIALOGS ---

  void _showAddChildDialog(BuildContext context, Color cardColor, Color primaryText) {
    final TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Add New Child", style: TextStyle(color: primaryText, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: nameController,
          style: TextStyle(color: primaryText),
          decoration: InputDecoration(
            hintText: "Enter child's name",
            hintStyle: TextStyle(color: primaryText.withOpacity(0.5)),
            filled: true,
            fillColor: primaryText.withOpacity(0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: accentColor, foregroundColor: Colors.white),
            // ✅ Calls local method only
            onPressed: () => _addLocalChild(nameController.text),
            child: const Text("Add"),
          )
        ],
      ),
    );
  }

  // --- UI BUILDING ---

  @override
  Widget build(BuildContext context) {
    final appService = context.watch<AppService>();
    final lang = appService.currentLanguage;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFE7E7EC);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final primaryText = isDark ? Colors.white : const Color(0xFF1D1D1F);
    final secondaryText = isDark ? const Color(0xFFBDBDBD) : const Color(0xFF5A5A60);

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
          AppStrings.get('trackChild', lang),
          style: TextStyle(color: primaryText, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            color: primaryText,
            onPressed: () {
              final newLang = lang == 'en' ? 'ar' : 'en';
              appService.setLanguage(newLang);
            },
          ),
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: primaryText),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        elevation: 4,
        onPressed: _isSaving
            ? null
            : () {
          showDialog(
            context: context,
            builder: (_) => Dialog(
              backgroundColor: cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: SingleChildScrollView(
                child: Stack(
                  children: [
                    TrackingInputWidget(
                      language: lang,
                      onSave: (map) {
                        map['childId'] = _selectedChildId;
                        _addTrackingEntry(map);
                        Navigator.pop(context);
                      },
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: IconButton(
                        icon: Icon(Icons.close, color: secondaryText),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        label: _isSaving
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(AppStrings.get('addEntry', lang), style: const TextStyle(fontWeight: FontWeight.bold)),
        icon: _isSaving ? null : const Icon(Icons.add_rounded),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            // ✅ Child Selector Row with "Add Child" button
            _buildChildSelectorRow(cardColor, primaryText, secondaryText, isDark),
            const SizedBox(height: 20),

            Expanded(
              child: _isLoadingTracking
                  ? const Center(child: CircularProgressIndicator())
                  : _trackingHistory.isEmpty
                  ? _buildEmptyState(lang, secondaryText)
                  : ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: _trackingHistory.length,
                itemBuilder: (context, index) {
                  final entry = _trackingHistory[index];
                  return _buildHistoryCard(
                      entry: entry,
                      cardColor: cardColor,
                      primaryText: primaryText,
                      secondaryText: secondaryText,
                      isDark: isDark,
                      lang: lang
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildChildSelectorRow(Color cardColor, Color primaryText, Color secondaryText, bool isDark) {
    return Row(
      children: [
        // Dropdown
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.0 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: Colors.grey.withOpacity(isDark ? 0.2 : 0.1)),
            ),
            child: _isLoadingChildren
                ? const Center(child: Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))))
                : _children.isEmpty
                ? Center(child: Padding(padding: const EdgeInsets.all(12), child: Text("No children found", style: TextStyle(color: secondaryText))))
                : DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedChildId,
                isExpanded: true,
                icon: Icon(Icons.keyboard_arrow_down_rounded, color: accentColor),
                dropdownColor: cardColor,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryText,
                  fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
                ),
                items: _children
                    .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                    .toList(),
                onChanged: (value) async {
                  setState(() => _selectedChildId = value);
                  if (value != null) await _loadTrackingForChild(value);
                },
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // ✅ THE "ADD CHILD" BUTTON (UI Only)
        InkWell(
          onTap: () => _showAddChildDialog(context, cardColor, primaryText),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accentColor.withOpacity(0.3)),
            ),
            child: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String lang, Color secondaryText) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_edu, size: 64, color: secondaryText.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(AppStrings.get('noData', lang), style: TextStyle(fontSize: 16, color: secondaryText)),
          const SizedBox(height: 8),
          Text(AppStrings.get('tapAdd', lang), style: TextStyle(fontSize: 14, color: secondaryText.withOpacity(0.7))),
        ],
      ),
    );
  }

  Widget _buildHistoryCard({
    required Map<String, dynamic> entry,
    required Color cardColor,
    required Color primaryText,
    required Color secondaryText,
    required bool isDark,
    required String lang,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.0 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(isDark ? 0.2 : 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 16, color: accentColor),
                    const SizedBox(width: 8),
                    Text(
                      entry['date'] ?? '',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: primaryText),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit_outlined, size: 20, color: secondaryText),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => Dialog(
                            backgroundColor: cardColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            child: SingleChildScrollView(
                              child: Stack(
                                children: [
                                  TrackingInputWidget(
                                    language: lang,
                                    onSave: (map) {
                                      map['id'] = entry['id'];
                                      map['childId'] = _selectedChildId;
                                      _updateTrackingEntry(map);
                                      Navigator.pop(context);
                                    },
                                  ),
                                  Positioned(
                                    right: 8,
                                    top: 8,
                                    child: IconButton(
                                      icon: Icon(Icons.close, color: secondaryText),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (c) => AlertDialog(
                            backgroundColor: cardColor,
                            title: Text(AppStrings.get('confirm', lang), style: TextStyle(color: primaryText)),
                            content: Text(AppStrings.get('confirmDelete', lang), style: TextStyle(color: secondaryText)),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(c, false), child: Text(AppStrings.get('no', lang))),
                              TextButton(onPressed: () => Navigator.pop(c, true), child: Text(AppStrings.get('yes', lang), style: const TextStyle(color: Colors.red))),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await _deleteTrackingEntry(entry['id']);
                        }
                      },
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, thickness: 0.5),
            const SizedBox(height: 16),

            Row(
              children: [
                if (entry['weight'] != null && entry['weight'].toString().isNotEmpty)
                  Expanded(
                    child: _buildStatBadge(
                      icon: Icons.monitor_weight_outlined,
                      label: AppStrings.get('weight', lang),
                      value: '${entry['weight']} kg',
                      color: Colors.blueAccent,
                      isDark: isDark,
                    ),
                  ),
                if ((entry['weight'] != null && entry['weight'].toString().isNotEmpty) &&
                    (entry['feedingAmount'] != null && entry['feedingAmount'].toString().isNotEmpty))
                  const SizedBox(width: 12),
                if (entry['feedingAmount'] != null && entry['feedingAmount'].toString().isNotEmpty)
                  Expanded(
                    child: _buildStatBadge(
                      icon: Icons.water_drop_outlined,
                      label: AppStrings.get('feedingAmount', lang),
                      value: '${entry['feedingAmount']} ml',
                      color: Colors.orangeAccent,
                      isDark: isDark,
                    ),
                  ),
              ],
            ),

            if (entry['oxygenSaturation'] != null && entry['oxygenSaturation'].toString().isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildStatBadge(
                icon: Icons.air,
                label: AppStrings.get('oxygenSaturation', lang),
                value: '${entry['oxygenSaturation']}%',
                color: Colors.redAccent,
                isDark: isDark,
                fullWidth: true,
              ),
            ],

            if (entry['equipment'] != null && entry['equipment'].toString().isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildOutlinedBox(
                icon: Icons.medical_services_outlined,
                label: AppStrings.get('equipment', lang),
                content: entry['equipment'],
                primaryText: primaryText,
              ),
            ],

            if (entry['notes'] != null && entry['notes'].toString().isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildOutlinedBox(
                icon: Icons.note_alt_outlined,
                label: AppStrings.get('notes', lang),
                content: entry['notes'],
                primaryText: primaryText,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatBadge({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color.withOpacity(0.8), letterSpacing: 0.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutlinedBox({
    required IconData icon,
    required String label,
    required String content,
    required Color primaryText,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: accentColor),
              const SizedBox(width: 8),
              Text(
                label.toUpperCase(),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: accentColor, letterSpacing: 1.0),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: primaryText, height: 1.3),
          ),
        ],
      ),
    );
  }
}