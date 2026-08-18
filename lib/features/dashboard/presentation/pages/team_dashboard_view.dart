import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/metric_card.dart';
import '../../../../core/widgets/project_card.dart';
import '../../../inventory/presentation/pages/inventory_list_page.dart';
import '../../../inventory/presentation/providers/inventory_provider.dart';

class TeamDashboardView extends StatelessWidget {
  final Function(int)? onNavigateToTab;

  const TeamDashboardView({
    super.key,
    this.onNavigateToTab,
  });

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
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Text(
          'Dashboard',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary, size: 24),
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.rejected,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications')),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 600));
        },
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              Text(
                'Welcome, ABC Marketing 👋',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "Here's what's happening today.",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 18),

              // Hero Total Projects Card
              HeroTotalProjectsCard(
                totalProjects: 3,
                onTap: () {
                  if (onNavigateToTab != null) {
                    onNavigateToTab!(1); // Go to Projects tab
                  }
                },
              ),
              const SizedBox(height: 14),

              // Metric Cards Grid
              Row(
                children: [
                  Expanded(
                    child: MetricCard(
                      title: 'Available',
                      value: '128',
                      dotColor: AppColors.available,
                      onTap: () {
                        inventoryProvider.setStatusFilter('Available');
                        if (onNavigateToTab != null) onNavigateToTab!(2);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MetricCard(
                      title: 'Blocked',
                      value: '15',
                      dotColor: AppColors.blocked,
                      onTap: () {
                        inventoryProvider.setStatusFilter('Blocked');
                        if (onNavigateToTab != null) onNavigateToTab!(2);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: MetricCard(
                      title: 'Booked',
                      value: '82',
                      dotColor: AppColors.booked,
                      onTap: () {
                        inventoryProvider.setStatusFilter('Booked');
                        if (onNavigateToTab != null) onNavigateToTab!(2);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MetricCard(
                      title: 'Registered',
                      value: '25',
                      dotColor: AppColors.registered,
                      onTap: () {
                        inventoryProvider.setStatusFilter('Registered');
                        if (onNavigateToTab != null) onNavigateToTab!(2);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Recent Projects Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Projects',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      if (onNavigateToTab != null) {
                        onNavigateToTab!(1); // Go to projects tab
                      }
                    },
                    child: Text(
                      'View All',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Projects List
              ...projects.take(3).map((project) => ProjectCard(
                    project: project,
                    showTotalUnits: false,
                    onTap: () {
                      inventoryProvider.setSelectedProject(project.id);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => InventoryListPage(project: project),
                        ),
                      );
                    },
                  )),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
