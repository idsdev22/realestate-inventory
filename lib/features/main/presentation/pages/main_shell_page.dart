import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/syncr_drawer.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../dashboard/presentation/pages/admin_dashboard_view.dart';
import '../../../dashboard/presentation/pages/team_dashboard_view.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../../more/presentation/pages/more_page.dart';
import '../../../projects/presentation/pages/projects_page.dart';

import '../../../users/presentation/pages/users_list_page.dart';

class MainShellPage extends StatefulWidget {
  final int initialIndex;

  const MainShellPage({super.key, this.initialIndex = 0});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  late int _currentIndex;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isPromoterAdmin = authProvider.isPromoterAdmin;
    final isMarketingAdmin = authProvider.isMarketingAdmin;

    final showUsersTab = isPromoterAdmin || isMarketingAdmin;

    // Screens per role
    final List<Widget> pages = [
      isPromoterAdmin
          ? AdminDashboardView(
              onNavigateToTab: (index) => setState(() => _currentIndex = index),
            )
          : TeamDashboardView(
              onNavigateToTab: (index) => setState(() => _currentIndex = index),
            ),
      const ProjectsPage(),
      if (showUsersTab) const UsersListPage(showBackButton: false),
      const MorePage(),
    ];

    // Ensure current index is valid
    if (_currentIndex >= pages.length) {
      _currentIndex = pages.length - 1;
    }

    return Scaffold(
      key: _scaffoldKey,
      drawer: const SyncrDrawer(),
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            top: BorderSide(color: AppColors.borderLight, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.home_rounded,
                  label: isPromoterAdmin ? 'Dashboard' : 'Home',
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.apartment_rounded,
                  label: 'Projects',
                ),
                if (showUsersTab)
                  _buildNavItem(
                    index: 2,
                    icon: isPromoterAdmin
                        ? Icons.people_alt_rounded
                        : Icons.group_rounded,
                    label: isPromoterAdmin ? 'Users' : 'Team',
                  ),
                _buildNavItem(
                  index: showUsersTab ? 3 : 2,
                  icon: Icons.more_horiz_rounded,
                  label: 'More',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;

    return InkWell(
      onTap: () {
        if (index == 0 && _currentIndex != 0) {
          final provider = context.read<DashboardProvider>();
          provider.reset();
          provider.loadDashboardData();
        }
        setState(() {
          _currentIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
