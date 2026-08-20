import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/full_screen_image_viewer.dart';
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
          // Project Cover Image Banner
          if (selectedProject != null)
            _buildProjectCoverBanner(context, selectedProject),

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
            child: inventoryProvider.isLoading && filteredUnits.isEmpty
                ? _buildSkeletonList()
                : filteredUnits.isEmpty
                ? Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.filter_list_off_rounded,
                              size: 40,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No matching units found',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _searchController.text.isNotEmpty ||
                                    inventoryProvider.selectedStatusFilter !=
                                        'All'
                                ? 'Try clearing your search query or selecting a different status filter'
                                : 'No units are currently registered for this project',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (_searchController.text.isNotEmpty ||
                              inventoryProvider.selectedStatusFilter != 'All' ||
                              inventoryProvider.activeAdvancedFiltersCount >
                                  0) ...[
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: () {
                                _searchController.clear();
                                inventoryProvider.setSearchQuery('');
                                inventoryProvider.setStatusFilter('All');
                                inventoryProvider.clearAdvancedFilters();
                              },
                              icon: const Icon(Icons.refresh_rounded, size: 16),
                              label: Text(
                                'Reset All Filters',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: const BorderSide(
                                  color: AppColors.primary,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () =>
                        inventoryProvider.loadInventory(reset: true),
                    color: AppColors.primary,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 14.0,
                      ),
                      itemCount: filteredUnits.length,
                      itemBuilder: (context, index) {
                        final unit = filteredUnits[index];
                        final isSelected = selectedIds.contains(unit.id);

                        return UnitCard(
                          key: ValueKey('unit_${unit.id}'),
                          unit: unit,
                          isSelected: isSelected,
                          isSelectionMode: _isSelectionMode,
                          showFavorite: true,
                          onFavoriteToggle: () {
                            inventoryProvider.toggleFavorite(unit.id);
                          },
                          onLongPress: null,
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
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCoverBanner(BuildContext context, ProjectModel project) {
    final heroTag = 'project-cover-${project.id}';
    final imageUrl = project.imageUrl;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      height: 155,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image with Hero
            Hero(tag: heroTag, child: _buildCoverImage(imageUrl)),

            // Gradient Overlay for Readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.85),
                  ],
                  stops: const [0.0, 0.35, 1.0],
                ),
              ),
            ),

            // Top-right Full View & Zoom action badge
            Positioned(
              top: 10,
              right: 10,
              child: Material(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  onTap: () => _openFullScreenViewer(context, project, heroTag),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.35),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.zoom_in_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Full View & Zoom',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Project Metadata Overlay
            Positioned(
              left: 14,
              right: 14,
              bottom: 12,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                project.projectType,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (project.approvalDetails != null &&
                                project.approvalDetails!.trim().isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.available,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  project.approval,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          project.name,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.6),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              color: Colors.white70,
                              size: 13,
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                project.location.isNotEmpty
                                    ? '${project.location}${project.city.isNotEmpty ? ', ${project.city}' : ''}'
                                    : (project.city.isNotEmpty
                                          ? project.city
                                          : 'Prime Location'),
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Quick tap to full view circular zoom icon
                  Material(
                    color: Colors.white.withValues(alpha: 0.25),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () =>
                          _openFullScreenViewer(context, project, heroTag),
                      child: const Padding(
                        padding: EdgeInsets.all(7.0),
                        child: Icon(
                          Icons.fullscreen_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Whole Banner InkWell trigger
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _openFullScreenViewer(context, project, heroTag),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openFullScreenViewer(
    BuildContext context,
    ProjectModel project,
    String heroTag,
  ) {
    FullScreenImageViewer.open(
      context,
      imageUrl: project.imageUrl,
      heroTag: heroTag,
      title: project.name,
      subtitle: '${project.location}, ${project.city}',
    );
  }

  Widget _buildCoverImage(String imageUrl) {
    if (imageUrl.startsWith('data:image')) {
      try {
        final commaIndex = imageUrl.indexOf(',');
        final base64Data = commaIndex != -1
            ? imageUrl.substring(commaIndex + 1)
            : imageUrl;
        final bytes = base64Decode(base64Data);
        return Image.memory(
          bytes,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildCoverFallback(),
        );
      } catch (e) {
        return _buildCoverFallback();
      }
    }
    return Image.network(
      imageUrl,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildCoverFallback(),
    );
  }

  Widget _buildCoverFallback() {
    return Container(
      color: AppColors.primaryLight,
      child: const Center(
        child: Icon(
          Icons.apartment_rounded,
          size: 48,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildSkeletonList() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 90,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    width: 70,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: 140,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 80,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    width: 100,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
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
