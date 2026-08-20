import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/syncr_badge.dart';
import '../../../activity/presentation/pages/activity_log_page.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../company_admin/presentation/pages/companies_list_page.dart';
import '../../../company_admin/presentation/pages/company_admin_page.dart';
import '../../../inventory/presentation/pages/inventory_overview_page.dart';
import '../../../requests/presentation/pages/all_requests_page.dart';
import '../../../requests/presentation/pages/my_requests_page.dart';
import '../../../users/presentation/pages/users_list_page.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isPromoterAdmin = authProvider.isPromoterAdmin;
    final isMarketingAdmin = authProvider.isMarketingAdmin;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Card
            Container(
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
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.primarySurface,
                    child: Text(
                      authProvider.user?.initials ??
                          (isPromoterAdmin
                              ? 'PA'
                              : isMarketingAdmin
                              ? 'MA'
                              : 'SS'),
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authProvider.user?.name ?? authProvider.displayName,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          authProvider.user?.email ??
                              (isPromoterAdmin
                                  ? 'admin@syncr.test'
                                  : isMarketingAdmin
                                  ? 'abcmarketing@gmail.com'
                                  : 'staff@syncr.test'),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        SyncrBadge(
                          label:
                              authProvider.user?.roleFormatted ??
                              (isPromoterAdmin
                                  ? 'Promoter Admin'
                                  : isMarketingAdmin
                                  ? 'Marketing Team Admin'
                                  : 'Marketing Team User'),
                          type: isPromoterAdmin
                              ? SyncrBadgeType.active
                              : isMarketingAdmin
                              ? SyncrBadgeType.booked
                              : SyncrBadgeType.pending,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Promoter Administration (Only shown for Promoter Admin)
            if (isPromoterAdmin) ...[
              _buildSection(
                title: 'Promoter Administration',
                items: [
                  _buildMenuItem(
                    icon: Icons.corporate_fare_rounded,
                    title: 'Marketing Companies',
                    subtitle:
                        'Manage partner agencies, permissions & allocations',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CompaniesListPage(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.people_alt_rounded,
                    title: 'Users Management',
                    subtitle:
                        'Manage admin accounts, sales executive logins & permissions',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const UsersListPage(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.assignment_turned_in_outlined,
                    title: 'All Requests',
                    subtitle: 'Manage all block and booking requests globally',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AllRequestsPage(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.admin_panel_settings_outlined,
                    title: 'Promoter Admin Console',
                    subtitle: 'System dashboard & company operations overview',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CompanyAdminPage(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.pie_chart_outline_rounded,
                    title: 'Inventory Overview',
                    subtitle: 'Status breakdown & analytics',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const InventoryOverviewPage(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.history_rounded,
                    title: 'Activity Log',
                    subtitle: 'Audit trail of inventory & system modifications',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ActivityLogPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],

            // Agency Management (Shown for Marketing Team Admin)
            if (isMarketingAdmin) ...[
              _buildSection(
                title: 'Agency Management',
                items: [
                  _buildMenuItem(
                    icon: Icons.pie_chart_outline_rounded,
                    title: 'Inventory Overview',
                    subtitle: 'Status breakdown & analytics',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const InventoryOverviewPage(),
                        ),
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
                        MaterialPageRoute(
                          builder: (_) => const MyRequestsPage(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.history_rounded,
                    title: 'Activity Log',
                    subtitle: 'Recent agency activity logs',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ActivityLogPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],

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
                      const SnackBar(
                        content: Text('Help desk: support@syncr.app'),
                      ),
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
                leading: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.rejected,
                ),
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

  Widget _buildSection({required String title, required List<Widget> items}) {
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
      trailing: const Icon(
        Icons.chevron_right_rounded,
        size: 20,
        color: AppColors.textMuted,
      ),
      onTap: onTap,
    );
  }
}
