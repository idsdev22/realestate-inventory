import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/syncr_badge.dart';
import '../../../activity/presentation/pages/activity_log_page.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../company_admin/presentation/pages/add_edit_company_page.dart';
import '../../../company_admin/presentation/pages/companies_list_page.dart';
import '../../../company_admin/presentation/pages/company_admin_page.dart';
import '../../../inventory/presentation/pages/add_edit_unit_page.dart';
import '../../../inventory/presentation/pages/inventory_overview_page.dart';
import '../../../requests/presentation/pages/my_requests_page.dart';
import '../../../teams/presentation/pages/marketing_teams_page.dart';
import '../../../teams/presentation/pages/team_users_page.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isAdmin = authProvider.isAdmin;

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
          'More Options',
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
          children: [
            // User Profile Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.borderLight),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primaryLight,
                    child: Icon(
                      isAdmin ? Icons.admin_panel_settings_rounded : Icons.business_center_rounded,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authProvider.displayName,
                          style: GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          authProvider.user?.email ?? (isAdmin ? 'admin@syncr.test' : 'abcmarketing@gmail.com'),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        SyncrBadge(
                          label: isAdmin ? 'Promoter Admin' : 'Marketing Team',
                          type: isAdmin ? SyncrBadgeType.registered : SyncrBadgeType.booked,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Role Switcher Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.swap_horiz_rounded, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Switch Active Mode',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => authProvider.setRole(UserRole.admin),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isAdmin ? AppColors.primary : Colors.white,
                            foregroundColor: isAdmin ? Colors.white : AppColors.textPrimary,
                            elevation: 0,
                            side: BorderSide(
                              color: isAdmin ? AppColors.primary : AppColors.border,
                            ),
                          ),
                          child: const Text('Admin Panel'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => authProvider.setRole(UserRole.marketingTeam),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: !isAdmin ? AppColors.primary : Colors.white,
                            foregroundColor: !isAdmin ? Colors.white : AppColors.textPrimary,
                            elevation: 0,
                            side: BorderSide(
                              color: !isAdmin ? AppColors.primary : AppColors.border,
                            ),
                          ),
                          child: const Text('Marketing Team'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Promoter Administration Section (For promoter_admin)
            if (isAdmin) ...[
              _buildSection(
                title: 'Promoter Administration',
                items: [
                  _buildMenuItem(
                    icon: Icons.corporate_fare_rounded,
                    title: 'Marketing Companies',
                    subtitle: 'Manage partner agencies, permissions & allocations',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CompaniesListPage()),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.add_business_rounded,
                    title: 'Add Marketing Company',
                    subtitle: 'Register new marketing company (POST /companies)',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddEditCompanyPage()),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.admin_panel_settings_outlined,
                    title: 'Company Admin Console',
                    subtitle: 'Promoter administrative control panel',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CompanyAdminPage()),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],

            // Features Menu Section
            _buildSection(
              title: 'Features & Modules',
              items: [
                _buildMenuItem(
                  icon: Icons.pie_chart_outline_rounded,
                  title: 'Inventory Overview',
                  subtitle: 'Status breakdown & analytics',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const InventoryOverviewPage()),
                    );
                  },
                ),
                _buildMenuItem(
                  icon: Icons.add_home_work_rounded,
                  title: 'Add / Edit Unit',
                  subtitle: 'Create or modify plot specifications',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddEditUnitPage()),
                    );
                  },
                ),
                _buildMenuItem(
                  icon: Icons.group_outlined,
                  title: 'Marketing Teams',
                  subtitle: 'Manage agency partnerships',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MarketingTeamsPage()),
                    );
                  },
                ),
                _buildMenuItem(
                  icon: Icons.assignment_outlined,
                  title: 'My Requests',
                  subtitle: 'Track block and booking approvals',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyRequestsPage()),
                    );
                  },
                ),
                _buildMenuItem(
                  icon: Icons.people_outline_rounded,
                  title: 'Team & Users',
                  subtitle: 'Manage sales executives and agents',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TeamUsersPage()),
                    );
                  },
                ),
                _buildMenuItem(
                  icon: Icons.history_rounded,
                  title: 'Activity Log',
                  subtitle: 'Audit trail of inventory modifications',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ActivityLogPage()),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Settings & System
            _buildSection(
              title: 'Settings',
              items: [
                _buildMenuItem(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notifications',
                  subtitle: 'Push alerts & email updates',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Notifications settings')),
                    );
                  },
                ),
                _buildMenuItem(
                  icon: Icons.security_rounded,
                  title: 'Data & Security',
                  subtitle: 'Role-based access & encryption',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Security & permissions')),
                    );
                  },
                ),
                _buildMenuItem(
                  icon: Icons.help_outline_rounded,
                  title: 'Support & Help',
                  subtitle: 'Documentation & contact desk',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Help desk: support@syncr.app')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Logout Button
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: ListTile(
                leading: const Icon(Icons.logout_rounded, color: AppColors.rejected),
                title: Text(
                  'Logout from Session',
                  style: GoogleFonts.poppins(
                    color: AppColors.rejected,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
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
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.borderLight),
          ...items,
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(
          fontSize: 11,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textMuted),
      onTap: onTap,
    );
  }
}
