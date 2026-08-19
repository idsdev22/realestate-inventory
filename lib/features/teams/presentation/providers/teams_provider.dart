import 'package:flutter/material.dart';
import 'package:realestate_inventory/features/activity/data/models/activity_log_model.dart';
import 'package:realestate_inventory/features/activity/data/services/activity_service.dart';
import 'package:realestate_inventory/features/teams/data/models/team_model.dart';
import 'package:realestate_inventory/core/utils/app_logger.dart';

class TeamsProvider extends ChangeNotifier {
  final ActivityService? _activityService;

  List<MarketingTeamModel> _teams = [];
  List<UserMemberModel> _users = [];
  List<ActivityLogModel> _activities = [];
  String _teamSearchQuery = '';
  String _activitySearchQuery = '';
  String _activityFilter = 'All Activities';
  bool _isLoadingActivities = false;
  int _activityPage = 1;
  bool _hasMoreActivities = true;
  bool _isLoadingMoreActivities = false;

  TeamsProvider({ActivityService? activityService}) : _activityService = activityService {
    _initializeDefaultData();
  }

  List<MarketingTeamModel> get teams => _teams;
  List<UserMemberModel> get users => _users;
  List<ActivityLogModel> get activities => _activities;
  String get teamSearchQuery => _teamSearchQuery;
  String get activitySearchQuery => _activitySearchQuery;
  String get activityFilter => _activityFilter;
  bool get isLoadingActivities => _isLoadingActivities;
  bool get isLoadingMoreActivities => _isLoadingMoreActivities;
  bool get hasMoreActivities => _hasMoreActivities;

  List<MarketingTeamModel> get filteredTeams {
    if (_teamSearchQuery.trim().isEmpty) return _teams;
    final q = _teamSearchQuery.toLowerCase().trim();
    return _teams.where((t) =>
      t.name.toLowerCase().contains(q) ||
      t.email.toLowerCase().contains(q) ||
      t.status.toLowerCase().contains(q)
    ).toList();
  }

  List<ActivityLogModel> get filteredActivities {
    List<ActivityLogModel> result = _activities;

    if (_activitySearchQuery.trim().isNotEmpty) {
      final q = _activitySearchQuery.toLowerCase().trim();
      result = result.where((a) {
        return a.description.toLowerCase().contains(q) ||
            a.actor.toLowerCase().contains(q) ||
            (a.entityType?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    if (_activityFilter == 'All Activities') return result;
    return result.where((a) {
      if (_activityFilter == 'Status Changes') {
        return a.type == ActivityType.statusBlocked || a.type == ActivityType.statusBooked;
      } else if (_activityFilter == 'Unit Updates') {
        return a.type == ActivityType.unitUpdated || a.type == ActivityType.unitAdded;
      } else if (_activityFilter == 'Price Updates') {
        return a.type == ActivityType.priceUpdated;
      }
      return true;
    }).toList();
  }

  void setTeamSearchQuery(String query) {
    _teamSearchQuery = query;
    notifyListeners();
  }

  void setActivitySearchQuery(String query) {
    _activitySearchQuery = query;
    notifyListeners();
  }

  void setActivityFilter(String filter) {
    _activityFilter = filter;
    notifyListeners();
  }

  void addTeam(MarketingTeamModel team) {
    _teams.insert(0, team);
    notifyListeners();
  }

  void addUser(UserMemberModel user) {
    _users.add(user);
    notifyListeners();
  }

  void addActivity(ActivityLogModel activity) {
    _activities.insert(0, activity);
    notifyListeners();
  }

  Future<void> fetchActivities({bool refresh = false}) async {
    if (_activityService == null) return;
    
    if (refresh) {
      _activityPage = 1;
      _hasMoreActivities = true;
    }

    if (!_hasMoreActivities || _isLoadingActivities || _isLoadingMoreActivities) return;

    if (_activityPage == 1) {
      _isLoadingActivities = true;
    } else {
      _isLoadingMoreActivities = true;
    }
    notifyListeners();

    try {
      final newActivities = await _activityService.getActivities(
        page: _activityPage,
        limit: 20,
      );
      
      if (newActivities.isEmpty) {
        _hasMoreActivities = false;
      } else {
        if (_activityPage == 1) {
          _activities = newActivities;
        } else {
          _activities.addAll(newActivities);
        }
        _activityPage++;
      }
    } catch (e) {
      AppLogger.e('Error fetching activities', e);
      if (_activityPage == 1) {
        _activities = [];
      }
    } finally {
      _isLoadingActivities = false;
      _isLoadingMoreActivities = false;
      notifyListeners();
    }
  }

  void _initializeDefaultData() {
    _teams = [
      MarketingTeamModel(
        id: 'team_1',
        name: 'ABC Marketing',
        email: 'abcmarketing@gmail.com',
        userCount: 12,
        projectCount: 2,
        status: 'Active',
        avatarBgColor: const Color(0xFF5C54E5),
      ),
      MarketingTeamModel(
        id: 'team_2',
        name: 'XYZ Realtors',
        email: 'xyzrealtors@gmail.com',
        userCount: 8,
        projectCount: 3,
        status: 'Active',
        avatarBgColor: const Color(0xFF10B981),
      ),
      MarketingTeamModel(
        id: 'team_3',
        name: 'PQR Properties',
        email: 'pqrproperties@gmail.com',
        userCount: 5,
        projectCount: 1,
        status: 'Active',
        avatarBgColor: const Color(0xFF3B82F6),
      ),
      MarketingTeamModel(
        id: 'team_4',
        name: 'LMN Developers',
        email: 'lmndevelopers@gmail.com',
        userCount: 6,
        projectCount: 2,
        status: 'Inactive',
        avatarBgColor: const Color(0xFF94A3B8),
      ),
      MarketingTeamModel(
        id: 'team_5',
        name: 'Sunrise Marketing',
        email: 'sunrisemkt@gmail.com',
        userCount: 4,
        projectCount: 1,
        status: 'Active',
        avatarBgColor: const Color(0xFF8B5CF6),
      ),
    ];

    _users = [
      UserMemberModel(
        id: 'u_1',
        name: 'Kumar',
        role: 'Team Admin',
        email: 'kumar@abc.com',
        avatarBgColor: const Color(0xFF635BFF),
        initial: 'K',
      ),
      UserMemberModel(
        id: 'u_2',
        name: 'Arun',
        role: 'Sales Executive',
        email: 'arun@abc.com',
        avatarBgColor: const Color(0xFF3B82F6),
        initial: 'A',
      ),
      UserMemberModel(
        id: 'u_3',
        name: 'Suresh',
        role: 'Sales Executive',
        email: 'suresh@abc.com',
        avatarBgColor: const Color(0xFF8B5CF6),
        initial: 'S',
      ),
      UserMemberModel(
        id: 'u_4',
        name: 'Priya',
        role: 'Sales Executive',
        email: 'priya@abc.com',
        avatarBgColor: const Color(0xFFEC4899),
        initial: 'P',
      ),
      UserMemberModel(
        id: 'u_5',
        name: 'Vignesh',
        role: 'Sales Executive',
        email: 'vignesh@abc.com',
        avatarBgColor: const Color(0xFF4F46E5),
        initial: 'V',
      ),
    ];
  }
}
