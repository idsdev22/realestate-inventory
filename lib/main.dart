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
import 'features/requests/presentation/providers/all_requests_provider.dart';
import 'features/requests/data/services/request_service.dart';
import 'features/activity/presentation/providers/activity_provider.dart';
import 'features/activity/data/services/activity_service.dart';

import 'features/projects/data/services/project_service.dart';
import 'features/inventory/data/services/inventory_service.dart';
import 'features/company_admin/data/services/company_service.dart';
import 'features/company_admin/presentation/providers/company_provider.dart';
import 'features/users/data/services/user_service.dart';
import 'features/users/presentation/providers/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = await StorageService.init();
  final apiService = ApiService(storageService: storageService);
  final authService = AuthService(apiService);
  final dashboardService = DashboardService(apiService);
  final projectService = ProjectService(apiService);
  final inventoryService = InventoryService(apiService);
  final companyService = CompanyService(apiService);
  final userService = UserService(apiService);
  final requestService = RequestService(apiService: apiService);
  final activityService = ActivityService(apiService: apiService);

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
          create: (_) => RequestsProvider(requestService: requestService),
        ),
        ChangeNotifierProvider<AllRequestsProvider>(
          create: (_) => AllRequestsProvider(requestService: requestService),
        ),
        ChangeNotifierProvider<ActivityProvider>(
          create: (_) => ActivityProvider(activityService: activityService),
        ),
        ChangeNotifierProvider<CompanyProvider>(
          create: (_) => CompanyProvider(companyService),
        ),
        ChangeNotifierProvider<UserProvider>(
          create: (_) => UserProvider(userService),
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
