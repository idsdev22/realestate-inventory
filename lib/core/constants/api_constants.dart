class ApiConstants {
  static const String baseUrl = 'https://superfinelabels.in/plots/index.php/api';

  // Auth Endpoints
  static const String login = '/auth/login';
  static const String forgotPassword = '/auth/forgot';
  static const String me = '/auth/me';
  static const String logout = '/auth/logout';

  // Dashboard Endpoints
  static const String dashboard = '/dashboard';
  static const String dashboardCharts = '/dashboard/charts';

  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static const Duration timeout = Duration(seconds: 15);
}
