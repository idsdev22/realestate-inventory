import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/network/api_service.dart';
import 'core/storage/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/services/auth_service.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/dashboard/data/services/dashboard_service.dart';
import 'features/dashboard/presentation/providers/dashboard_provider.dart';
import 'features/inventory/presentation/providers/inventory_provider.dart';
import 'features/requests/presentation/providers/requests_provider.dart';
import 'features/teams/presentation/providers/teams_provider.dart';

import 'features/projects/data/services/project_service.dart';
import 'features/inventory/data/services/inventory_service.dart';
import 'features/company_admin/data/services/company_service.dart';
import 'features/company_admin/presentation/providers/company_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = await StorageService.init();
  final apiService = ApiService(storageService: storageService);
  final authService = AuthService(apiService);
  final dashboardService = DashboardService(apiService);
  final projectService = ProjectService(apiService);
  final inventoryService = InventoryService(apiService);
  final companyService = CompanyService(apiService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(
            authService: authService,
            storageService: storageService,
          ),
        ),
        ChangeNotifierProvider<DashboardProvider>(
          create: (_) => DashboardProvider(dashboardService),
        ),
        ChangeNotifierProvider<InventoryProvider>(
          create: (_) => InventoryProvider(
            projectService: projectService,
            inventoryService: inventoryService,
          ),
        ),
        ChangeNotifierProvider<RequestsProvider>(
          create: (_) => RequestsProvider(),
        ),
        ChangeNotifierProvider<TeamsProvider>(create: (_) => TeamsProvider()),
        ChangeNotifierProvider<CompanyProvider>(
          create: (_) => CompanyProvider(companyService),
        ),
      ],
      child: const RealEstateInventoryApp(),
    ),
  );
}

class RealEstateInventoryApp extends StatelessWidget {
  const RealEstateInventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SYNCR - Real Estate Inventory',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const SplashPage(),
    );
  }
}
