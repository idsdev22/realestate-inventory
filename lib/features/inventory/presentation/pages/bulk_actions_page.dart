import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../teams/presentation/providers/teams_provider.dart';
import 'package:realestate_inventory/features/inventory/data/models/unit_model.dart';
import '../providers/inventory_provider.dart';

class BulkActionsPage extends StatefulWidget {
  final List<UnitModel> selectedUnits;

  const BulkActionsPage({super.key, required this.selectedUnits});

  @override
  State<BulkActionsPage> createState() => _BulkActionsPageState();
}

class _BulkActionsPageState extends State<BulkActionsPage> {
  String _selectedAction = 'Change Status';
  String _newStatus = 'Blocked';
  final TextEditingController _remarksController = TextEditingController();
  late Set<int> _activeSelectedIds;

  final List<String> _actions = [
    'Change Status',
    'Update Price per sq.ft',
    'Assign Block',
  ];

  final List<String> _statuses = [
    'Available',
    'Blocked',
    'Booked',
    'Registered',
  ];

  @override
  void initState() {
    super.initState();
    _activeSelectedIds = widget.selectedUnits.map((u) => u.id).toSet();
  }

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  void _applyBulkUpdate() {
    final inventoryProvider = context.read<InventoryProvider>();
    context.read<TeamsProvider>();

    final updatedCount = _activeSelectedIds.length;
    if (updatedCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one unit to update'),
        ),
      );
      return;
    }

    inventoryProvider.bulkUpdateStatus(
      _activeSelectedIds.toList(),
      _newStatus,
      remarks: _remarksController.text.trim().isNotEmpty
          ? _remarksController.text.trim()
          : null,
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.available,
        content: Text(
          'Successfully updated $updatedCount units to "$_newStatus"!',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final count = _activeSelectedIds.length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '$count Selected',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bulk Update Title
            Text(
              'Bulk Update',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // Action Selector
            Text(
              'Action',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            _buildDropdown(
              value: _selectedAction,
              items: _actions,
              onChanged: (val) => setState(() => _selectedAction = val!),
            ),
            const SizedBox(height: 16),

            // New Status Selector
            Text(
              'New Status',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            _buildDropdown(
              value: _newStatus,
              items: _statuses,
              onChanged: (val) => setState(() => _newStatus = val!),
            ),
            const SizedBox(height: 16),

            // Remarks
            Text(
              'Remarks (Optional)',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _remarksController,
              maxLines: 2,
              style: GoogleFonts.poppins(fontSize: 14),
              decoration: const InputDecoration(hintText: 'Enter remarks'),
            ),
            const SizedBox(height: 20),

            // Update Units Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyBulkUpdate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Update $count Units',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Selected Units Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Selected Units',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      if (_activeSelectedIds.length ==
                          widget.selectedUnits.length) {
                        _activeSelectedIds.clear();
                      } else {
                        _activeSelectedIds = widget.selectedUnits
                            .map((u) => u.id)
                            .toSet();
                      }
                    });
                  },
                  child: Text(
                    _activeSelectedIds.length == widget.selectedUnits.length
                        ? 'Deselect All'
                        : 'Select All',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Selected Units List
            ...widget.selectedUnits.map((unit) {
              final isChecked = _activeSelectedIds.contains(unit.id);
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isChecked ? AppColors.primarySurface : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isChecked
                        ? AppColors.primaryLight
                        : AppColors.borderLight,
                  ),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: isChecked,
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _activeSelectedIds.add(unit.id);
                          } else {
                            _activeSelectedIds.remove(unit.id);
                          }
                        });
                      },
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      unit.unitNo,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      unit.blockPhase ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${unit.areaSqFt} sq.ft',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textSecondary,
          ),
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
          items: items.map((val) {
            return DropdownMenuItem<String>(value: val, child: Text(val));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
