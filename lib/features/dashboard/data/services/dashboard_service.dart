import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_service.dart';
import '../models/dashboard_model.dart';

class DashboardService {
  final ApiService _apiService;

  DashboardService(this._apiService);

  Future<DashboardModel> getDashboard() async {
    final response = await _apiService.get(ApiConstants.dashboard);

    if (response is Map<String, dynamic>) {
      return DashboardModel.fromJson(response);
    }
    throw Exception('Failed to load dashboard data');
  }

  Future<DashboardChartsModel> getDashboardCharts() async {
    final response = await _apiService.get(ApiConstants.dashboardCharts);

    if (response is Map<String, dynamic>) {
      return DashboardChartsModel.fromJson(response);
    }
    return DashboardChartsModel(statusPie: []);
  }
}
