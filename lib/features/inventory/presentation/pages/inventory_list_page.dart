import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/unit_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../projects/data/models/project_model.dart';
import '../../../projects/presentation/pages/add_edit_project_page.dart';
import '../providers/inventory_provider.dart';
import 'add_edit_unit_page.dart';
import 'bulk_actions_page.dart';
import 'unit_details_page.dart';
import '../widgets/inventory_filter_sheet.dart';

class InventoryListPage extends StatefulWidget {
  final ProjectModel? project;

  const InventoryListPage({super.key, this.project});

  @override
  State<InventoryListPage> createState() => _InventoryListPageState();
}

class _InventoryListPageState extends State<InventoryListPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    if (widget.project != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<InventoryProvider>().setSelectedProject(
          widget.project!.id,
        );
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openBulkActions(BuildContext context, InventoryProvider provider) {
    final selectedUnits = provider.units
        .where((u) => provider.selectedUnitIds.contains(u.id))
        .toList();

    if (selectedUnits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one unit')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BulkActionsPage(selectedUnits: selectedUnits),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const InventoryFilterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final inventoryProvider = context.watch<InventoryProvider>();
    final isPromoterAdmin = authProvider.isPromoterAdmin;
    final isRoot = ModalRoute.of(context)?.canPop != true;

    final selectedProject = widget.project ?? inventoryProvider.selectedProject;
    final projectName = selectedProject?.name ?? 'Royal City';
    final filteredUnits = inventoryProvider.filteredUnits;
    final selectedIds = inventoryProvider.selectedUnitIds;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: isRoot
            ? Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(
                    Icons.menu_rounded,
                    color: AppColors.textPrimary,
                  ),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              )
            : IconButton(
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.textPrimary,
                ),
                onPressed: () => Navigator.pop(context),
              ),
        title: Text(
          projectName,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          if (isPromoterAdmin) ...[
            if (_isSelectionMode)
              TextButton(
                onPressed: () {
                  setState(() => _isSelectionMode = false);
                  inventoryProvider.clearSelection();
                },
                child: Text(
                  'Done',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              )
            else ...[
              if (selectedProject != null)
                IconButton(
                  tooltip: 'Edit Project',
                  icon: const Icon(
                    Icons.edit_note_rounded,
                    color: AppColors.textPrimary,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AddEditProjectPage(project: selectedProject),
                        fullscreenDialog: true,
                      ),
                    );
                  },
                ),
              IconButton(
                tooltip: 'Add Unit',
                icon: const Icon(Icons.add_rounded, color: AppColors.primary),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddEditUnitPage(project: selectedProject),
                    ),
                  );
                },
              ),
            ],
          ] else ...[
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.tune_rounded,
                    color: AppColors.textPrimary,
                  ),
                  onPressed: () => _showFilterSheet(context),
                ),
                if (inventoryProvider.activeAdvancedFiltersCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${inventoryProvider.activeAdvancedFiltersCount}',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search Bar & Filter Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Column(
              children: [
                // Search Input
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) =>
                              inventoryProvider.setSearchQuery(val),
                          style: GoogleFonts.poppins(fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Search plot / unit',
                            hintStyle: GoogleFonts.poppins(
                              color: AppColors.textMuted,
                              fontSize: 14,
                            ),
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: AppColors.textMuted,
                              size: 22,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.clear_rounded,
                                      size: 18,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      inventoryProvider.setSearchQuery('');
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.tune_rounded,
                              color: AppColors.iconColor,
                              size: 20,
                            ),
                            onPressed: () => _showFilterSheet(context),
                          ),
                        ),
                        if (inventoryProvider.activeAdvancedFiltersCount > 0)
                          Positioned(
                            right: -4,
                            top: -4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${inventoryProvider.activeAdvancedFiltersCount}',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Horizontal Filter Status Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        context,
                        label: 'All (${inventoryProvider.countAll})',
                        status: 'All',
                        isSelected:
                            inventoryProvider.selectedStatusFilter == 'All',
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        context,
                        label:
                            'Available (${inventoryProvider.countAvailable})',
                        status: 'Available',
                        isSelected:
                            inventoryProvider.selectedStatusFilter ==
                            'Available',
                        activeBgColor: const Color(0xFFE8F8F0),
                        activeTextColor: AppColors.available,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        context,
                        label: 'Blocked (${inventoryProvider.countBlocked})',
                        status: 'Blocked',
                        isSelected:
                            inventoryProvider.selectedStatusFilter == 'Blocked',
                        activeBgColor: const Color(0xFFFEF3E2),
                        activeTextColor: AppColors.blocked,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        context,
                        label: 'Booked (${inventoryProvider.countBooked})',
                        status: 'Booked',
                        isSelected:
                            inventoryProvider.selectedStatusFilter == 'Booked',
                        activeBgColor: const Color(0xFFEBF3FE),
                        activeTextColor: AppColors.booked,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Selection Mode Action Strip (For Admin Bulk Actions)
          if (_isSelectionMode)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              color: AppColors.primarySurface,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${selectedIds.length} Selected',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          inventoryProvider.selectAll(
                            filteredUnits.map((u) => u.id).toList(),
                          );
                        },
                        child: Text(
                          'Select All',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () =>
                            _openBulkActions(context, inventoryProvider),
                        child: Text(
                          'Bulk Actions',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Unit Cards List
          Expanded(
            child: filteredUnits.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_rounded,
                          size: 56,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No units found',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Try changing status filter or search query',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 16.0,
                    ),
                    itemCount: filteredUnits.length,
                    itemBuilder: (context, index) {
                      final unit = filteredUnits[index];
                      final isSelected = selectedIds.contains(unit.id);

                      return UnitCard(
                        unit: unit,
                        isSelected: isSelected,
                        isSelectionMode: _isSelectionMode,
                        showFavorite: true,
                        onFavoriteToggle: () {
                          inventoryProvider.toggleFavorite(unit.id);
                        },
                        onLongPress: null, // Bulk actions hidden overall
                        onTap: () {
                          if (_isSelectionMode) {
                            inventoryProvider.toggleSelection(unit.id);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UnitDetailsPage(unit: unit),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required String status,
    required bool isSelected,
    Color? activeBgColor,
    Color? activeTextColor,
  }) {
    final bgColor = isSelected
        ? (activeBgColor ?? AppColors.primaryLight)
        : AppColors.background;
    final textColor = isSelected
        ? (activeTextColor ?? AppColors.primary)
        : AppColors.textSecondary;

    return InkWell(
      onTap: () {
        context.read<InventoryProvider>().setStatusFilter(status);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (activeTextColor ?? AppColors.primary).withValues(alpha: 0.3)
                : AppColors.borderLight,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
