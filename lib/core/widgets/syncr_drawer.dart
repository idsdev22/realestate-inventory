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
import '../../features/requests/presentation/pages/all_requests_page.dart';
import '../../features/requests/presentation/pages/my_requests_page.dart';
import '../../features/users/presentation/pages/users_list_page.dart';
import '../theme/app_theme.dart';
import 'syncr_badge.dart';

class SyncrDrawer extends StatelessWidget {
  const SyncrDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isPromoterAdmin = authProvider.isPromoterAdmin;
    final isMarketingAdmin = authProvider.isMarketingAdmin;
    final isStaffUser = authProvider.isStaffUser;

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.borderLight),
                ),
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
                    authProvider.user?.email ??
                        (isPromoterAdmin
                            ? ''
                            : isMarketingAdmin
                            ? ''
                            : ''),
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SyncrBadge(
                    label: isPromoterAdmin
                        ? 'Promoter Admin'
                        : isMarketingAdmin
                        ? 'Marketing Team Admin'
                        : 'Marketing Team User',
                    type: isPromoterAdmin
                        ? SyncrBadgeType.active
                        : isMarketingAdmin
                        ? SyncrBadgeType.booked
                        : SyncrBadgeType.pending,
                  ),
                ],
              ),
            ),

            // 3-Way Role Switcher Toggle
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        if (!isPromoterAdmin) {
                          authProvider.setRole(UserRole.admin);
                        }
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        decoration: BoxDecoration(
                          color: isPromoterAdmin
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'Admin',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isPromoterAdmin
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        if (!isMarketingAdmin) {
                          authProvider.setRole(UserRole.marketingTeam);
                        }
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        decoration: BoxDecoration(
                          color: isMarketingAdmin
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'Marketing',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isMarketingAdmin
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        if (!isStaffUser) {
                          authProvider.setRole(UserRole.staffs);
                        }
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        decoration: BoxDecoration(
                          color: isStaffUser
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'Staff',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isStaffUser
                                  ? Colors.white
                                  : AppColors.textSecondary,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                children: [
                  if (isPromoterAdmin) ...[
                    _buildNavItem(
                      context,
                      icon: Icons.corporate_fare_rounded,
                      title: 'Marketing Companies',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CompaniesListPage(),
                          ),
                        );
                      },
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.people_alt_outlined,
                      title: 'Users Management',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const UsersListPage(),
                          ),
                        );
                      },
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.assignment_turned_in_outlined,
                      title: 'All Requests',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AllRequestsPage(),
                          ),
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
                          MaterialPageRoute(
                            builder: (_) => const InventoryOverviewPage(),
                          ),
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
                          MaterialPageRoute(
                            builder: (_) => const AddEditUnitPage(),
                          ),
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
                          MaterialPageRoute(
                            builder: (_) => const CompanyAdminPage(),
                          ),
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
                          MaterialPageRoute(
                            builder: (_) => const ActivityLogPage(),
                          ),
                        );
                      },
                    ),
                  ] else if (isMarketingAdmin) ...[
                    _buildNavItem(
                      context,
                      icon: Icons.assignment_outlined,
                      title: 'My Requests',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MyRequestsPage(),
                          ),
                        );
                      },
                    ),
                  ] else ...[
                    _buildNavItem(
                      context,
                      icon: Icons.pie_chart_outline_rounded,
                      title: 'Inventory Overview',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const InventoryOverviewPage(),
                          ),
                        );
                      },
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.assignment_outlined,
                      title: 'My Requests',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MyRequestsPage(),
                          ),
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
                leading: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.rejected,
                ),
                title: Text(
                  'Logout',
                  style: GoogleFonts.poppins(
                    color: AppColors.rejected,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
      trailing: const Icon(
        Icons.chevron_right_rounded,
        size: 20,
        color: AppColors.textMuted,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: onTap,
    );
  }
}
