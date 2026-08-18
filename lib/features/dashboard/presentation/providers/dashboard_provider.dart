import 'package:flutter/foundation.dart';
import '../../../../core/network/api_exception.dart';
import '../../data/models/dashboard_model.dart';
import '../../data/services/dashboard_service.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardService _dashboardService;

  DashboardModel? _dashboardData;
  DashboardChartsModel? _chartsData;
  bool _isLoading = false;
  String? _errorMessage;

  DashboardProvider(this._dashboardService);

  DashboardModel? get dashboardData => _dashboardData;
  DashboardChartsModel? get chartsData => _chartsData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasData => _dashboardData != null;

  Future<void> loadDashboardData({bool isRefresh = false}) async {
    if (!isRefresh && _dashboardData != null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _dashboardService.getDashboard(),
        _dashboardService.getDashboardCharts(),
      ]);

      _dashboardData = results[0] as DashboardModel;
      _chartsData = results[1] as DashboardChartsModel;
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to load dashboard. Please try again.';
      debugPrint('Dashboard error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await loadDashboardData(isRefresh: true);
  }

  void reset() {
    _dashboardData = null;
    _chartsData = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
