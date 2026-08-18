import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/activity/presentation/pages/activity_log_page.dart';
import '../../features/company_admin/presentation/pages/companies_list_page.dart';
import '../../features/company_admin/presentation/pages/company_admin_page.dart';
import '../../features/inventory/presentation/pages/add_edit_unit_page.dart';
import '../../features/inventory/presentation/pages/inventory_overview_page.dart';
import '../../features/requests/presentation/pages/my_requests_page.dart';
import '../../features/teams/presentation/pages/marketing_teams_page.dart';
import '../../features/teams/presentation/pages/team_users_page.dart';
import '../theme/app_theme.dart';
import 'syncr_badge.dart';

class SyncrDrawer extends StatelessWidget {
  const SyncrDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isAdmin = authProvider.isAdmin;

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.borderLight)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.grid_view_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'SYNCR',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    authProvider.displayName,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    authProvider.user?.email ?? (isAdmin ? 'admin@syncr.test' : 'abcmarketing@gmail.com'),
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SyncrBadge(
                    label: isAdmin ? 'Promoter Admin' : 'Marketing Agency',
                    type: isAdmin ? SyncrBadgeType.registered : SyncrBadgeType.booked,
                  ),
                ],
              ),
            ),

            // Role Switcher Toggle
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        if (!isAdmin) {
                          authProvider.setRole(UserRole.admin);
                          Navigator.pop(context);
                        }
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isAdmin ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: isAdmin
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 4,
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            'Admin Role',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: isAdmin ? FontWeight.bold : FontWeight.w500,
                              color: isAdmin ? AppColors.primary : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        if (isAdmin) {
                          authProvider.setRole(UserRole.marketingTeam);
                          Navigator.pop(context);
                        }
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: !isAdmin ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: !isAdmin
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 4,
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            'Team Role',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: !isAdmin ? FontWeight.bold : FontWeight.w500,
                              color: !isAdmin ? AppColors.primary : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Navigation Links
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                children: [
                  if (isAdmin) ...[
                    _buildNavItem(
                      context,
                      icon: Icons.corporate_fare_rounded,
                      title: 'Marketing Companies',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CompaniesListPage()),
                        );
                      },
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.pie_chart_outline_rounded,
                      title: 'Inventory Overview',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const InventoryOverviewPage()),
                        );
                      },
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.add_circle_outline_rounded,
                      title: 'Add New Unit',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AddEditUnitPage()),
                        );
                      },
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.group_outlined,
                      title: 'Marketing Teams',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MarketingTeamsPage()),
                        );
                      },
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.admin_panel_settings_outlined,
                      title: 'Company Admin Console',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CompanyAdminPage()),
                        );
                      },
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.history_rounded,
                      title: 'Activity Log',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ActivityLogPage()),
                        );
                      },
                    ),
                  ] else ...[
                    _buildNavItem(
                      context,
                      icon: Icons.assignment_outlined,
                      title: 'My Requests',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MyRequestsPage()),
                        );
                      },
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.people_outline_rounded,
                      title: 'My Team & Users',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const TeamUsersPage()),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),

            // Footer / Logout
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.borderLight)),
              ),
              child: ListTile(
                leading: const Icon(Icons.logout_rounded, color: AppColors.rejected),
                title: Text(
                  'Logout',
                  style: GoogleFonts.poppins(
                    color: AppColors.rejected,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onTap: () async {
                  await authProvider.logout();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                      (route) => false,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary, size: 22),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textMuted),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: onTap,
    );
  }
}
