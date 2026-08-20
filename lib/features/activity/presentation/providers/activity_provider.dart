import 'package:flutter/foundation.dart';
import '../../data/models/activity_log_model.dart';
import '../../data/services/activity_service.dart';

class ActivityProvider extends ChangeNotifier {
  final ActivityService _activityService;

  List<ActivityLogModel> _activities = [];
  bool _isLoadingActivities = false;
  bool _isLoadingMoreActivities = false;
  String _activitySearchQuery = '';
  int _currentPage = 1;
  bool _hasMoreActivities = true;

  ActivityProvider({required ActivityService activityService})
      : _activityService = activityService;

  List<ActivityLogModel> get filteredActivities {
    if (_activitySearchQuery.isEmpty) return _activities;
    final query = _activitySearchQuery.toLowerCase();
    return _activities.where((act) {
      return act.actor.toLowerCase().contains(query) ||
             act.description.toLowerCase().contains(query);
    }).toList();
  }

  bool get isLoadingActivities => _isLoadingActivities;
  bool get isLoadingMoreActivities => _isLoadingMoreActivities;

  void setActivitySearchQuery(String query) {
    _activitySearchQuery = query;
    notifyListeners();
  }

  Future<void> fetchActivities({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMoreActivities = true;
      _isLoadingActivities = true;
      _activities.clear();
      notifyListeners();
    } else {
      if (!_hasMoreActivities || _isLoadingMoreActivities || _isLoadingActivities) return;
      _isLoadingMoreActivities = true;
      notifyListeners();
    }

    try {
      final newActivities = await _activityService.getActivities(
        page: _currentPage,
        limit: 20,
      );
      
      if (newActivities.isEmpty) {
        _hasMoreActivities = false;
      } else {
        _activities.addAll(newActivities);
        _currentPage++;
      }
    } catch (e) {
      debugPrint('Error fetching activities: $e');
    } finally {
      _isLoadingActivities = false;
      _isLoadingMoreActivities = false;
      notifyListeners();
    }
  }
}
