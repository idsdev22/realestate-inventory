import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../main/presentation/pages/main_shell_page.dart';
import 'admin_dashboard_view.dart';
import 'team_dashboard_view.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // If opened directly as a standalone route, render the MainShellPage
    return const MainShellPage();
  }
}

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    if (authProvider.isPromoterAdmin) {
      return const AdminDashboardView();
    } else {
      return const TeamDashboardView();
    }
  }
}
