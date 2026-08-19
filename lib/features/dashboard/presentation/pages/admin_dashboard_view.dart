import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/metric_card.dart';
import '../../../../core/widgets/project_card.dart';
import '../../../inventory/presentation/pages/inventory_list_page.dart';
import '../../../inventory/presentation/pages/inventory_overview_page.dart';
import '../../../inventory/presentation/providers/inventory_provider.dart';
import '../providers/dashboard_provider.dart';

class AdminDashboardView extends StatefulWidget {
  final Function(int)? onNavigateToTab;

  const AdminDashboardView({super.key, this.onNavigateToTab});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = context.watch<DashboardProvider>();
    final inventoryProvider = context
        .read<InventoryProvider>(); // For navigation
    final dashboardData = dashboardProvider.dashboardData;

    final isLoading = dashboardProvider.isLoading && !dashboardProvider.hasData;

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
                const Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.textPrimary,
                  size: 24,
                ),
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await dashboardProvider.refresh();
              },
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Header
                    Text(
                      dashboardData?.greeting ?? 'Welcome, Admin 👋',
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
                      totalProjects: dashboardData?.totalProjects ?? 0,
                      onTap: () {
                        if (widget.onNavigateToTab != null) {
                          widget.onNavigateToTab!(1); // Go to Projects Tab
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
                            value:
                                dashboardData?.inventory.available.toString() ??
                                '0',
                            dotColor: AppColors.available,
                            onTap: () {
                              inventoryProvider.setStatusFilter('Available');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const InventoryListPage(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: MetricCard(
                            title: 'Blocked',
                            value:
                                dashboardData?.inventory.blocked.toString() ??
                                '0',
                            dotColor: AppColors.blocked,
                            onTap: () {
                              inventoryProvider.setStatusFilter('Blocked');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const InventoryListPage(),
                                ),
                              );
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
                            value:
                                dashboardData?.inventory.booked.toString() ??
                                '0',
                            dotColor: AppColors.booked,
                            onTap: () {
                              inventoryProvider.setStatusFilter('Booked');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const InventoryListPage(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: MetricCard(
                            title: 'Registered',
                            value: dashboardData?.inventory.total != null
                                ? (dashboardData!.inventory.total -
                                          dashboardData.inventory.available -
                                          dashboardData.inventory.blocked -
                                          dashboardData.inventory.booked)
                                      .toString()
                                : '0',
                            dotColor: AppColors.registered,
                            onTap: () {
                              inventoryProvider.setStatusFilter('Registered');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const InventoryListPage(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const InventoryOverviewPage(),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primarySurface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.primaryLight,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Overview',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Full Analytics',
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
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
                            if (widget.onNavigateToTab != null) {
                              widget.onNavigateToTab!(1); // Go to projects tab
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
                    if (dashboardData != null)
                      ...dashboardData.recentProjects
                          .take(3)
                          .map(
                            (project) => ProjectCard(
                              project: project,
                              showTotalUnits: false,
                              onTap: () {
                                inventoryProvider.setSelectedProject(
                                  project.id,
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        InventoryListPage(project: project),
                                  ),
                                );
                              },
                            ),
                          ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}
