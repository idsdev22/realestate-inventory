import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../projects/data/models/project_model.dart';
import '../providers/inventory_provider.dart';
import 'inventory_list_page.dart';

class InventoryOverviewPage extends StatefulWidget {
  const InventoryOverviewPage({super.key});

  @override
  State<InventoryOverviewPage> createState() => _InventoryOverviewPageState();
}

class _InventoryOverviewPageState extends State<InventoryOverviewPage> {
  String _selectedProjectFilter = 'All Projects';

  @override
  Widget build(BuildContext context) {
    final inventoryProvider = context.watch<InventoryProvider>();
    final projects = inventoryProvider.projects;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Inventory Overview',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project Selector & Date Picker Bar
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: (projects.any((p) => p.name == _selectedProjectFilter) || _selectedProjectFilter == 'All Projects') 
                            ? _selectedProjectFilter 
                            : 'All Projects',
                        isExpanded: true,
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.textSecondary,
                        ),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        items: [
                          'All Projects',
                          ...projects.map((p) => p.name),
                        ].map((String val) {
                          return DropdownMenuItem<String>(
                            value: val,
                            child: Text(val),
                          );
                        }).toList(),
                        onChanged: (newVal) {
                          if (newVal != null) {
                            setState(() => _selectedProjectFilter = newVal);
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: const Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.iconColor,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Stat Summary Metric Cards Grid
            Row(
              children: [
                Expanded(
                  child: _buildSummaryBox(
                    title: 'Total Units',
                    value: '1,250',
                    badgeColor: null,
                    textColor: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildSummaryBox(
                    title: 'Available',
                    value: '680',
                    badgeColor: AppColors.available,
                    textColor: AppColors.available,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildSummaryBox(
                    title: 'Blocked',
                    value: '120',
                    badgeColor: AppColors.blocked,
                    textColor: AppColors.blocked,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryBox(
                    title: 'Booked',
                    value: '320',
                    badgeColor: AppColors.booked,
                    textColor: AppColors.booked,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildSummaryBox(
                    title: 'Registered',
                    value: '130',
                    badgeColor: AppColors.registered,
                    textColor: AppColors.registered,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // "Inventory by Project" Section
            Text(
              'Inventory by Project',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // Projects Breakdown List
            ...projects.map((project) => _buildProjectInventoryRow(context, project)),

            const SizedBox(height: 24),

            // Legend at Bottom
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLegendItem('Available', AppColors.available),
                  _buildLegendItem('Blocked', AppColors.blocked),
                  _buildLegendItem('Booked', AppColors.booked),
                  _buildLegendItem('Registered', AppColors.registered),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryBox({
    required String title,
    required String value,
    Color? badgeColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: badgeColor ?? AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectInventoryRow(BuildContext context, ProjectModel project) {
    return InkWell(
      onTap: () {
        context.read<InventoryProvider>().setSelectedProject(project.id);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => InventoryListPage(project: project),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project Name & Total Units
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  project.name,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                RichText(
                  text: TextSpan(
                    text: 'Total ',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                    children: [
                      TextSpan(
                        text: '${project.totalUnits}',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Segmented Badges with Color Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMetricDotItem('${project.availableUnits}', AppColors.available),
                _buildMetricDotItem('${project.blockedUnits}', AppColors.blocked),
                _buildMetricDotItem('${project.bookedUnits}', AppColors.booked),
                _buildMetricDotItem('${project.registeredUnits}', AppColors.registered),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricDotItem(String count, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          count,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
