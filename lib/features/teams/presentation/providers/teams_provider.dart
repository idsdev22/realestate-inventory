import 'package:flutter/material.dart';
import 'package:realestate_inventory/features/activity/data/models/activity_log_model.dart';
import 'package:realestate_inventory/features/teams/data/models/team_model.dart';

class TeamsProvider extends ChangeNotifier {
  List<MarketingTeamModel> _teams = [];
  List<UserMemberModel> _users = [];
  List<ActivityLogModel> _activities = [];
  String _teamSearchQuery = '';
  String _activityFilter = 'All Activities';

  TeamsProvider() {
    _initializeDefaultData();
  }

  List<MarketingTeamModel> get teams => _teams;
  List<UserMemberModel> get users => _users;
  List<ActivityLogModel> get activities => _activities;
  String get teamSearchQuery => _teamSearchQuery;
  String get activityFilter => _activityFilter;

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
    if (_activityFilter == 'All Activities') return _activities;
    return _activities.where((a) {
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

    _activities = [
      ActivityLogModel(
        id: 'act_1',
        description: 'A-101 status changed from Available to Blocked by Admin',
        actor: 'Admin',
        time: '10:30 AM',
        group: 'Today',
        type: ActivityType.statusBlocked,
      ),
      ActivityLogModel(
        id: 'act_2',
        description: 'A-102 status changed from Blocked to Booked by Sales Manager',
        actor: 'Sales Manager',
        time: '11:15 AM',
        group: 'Today',
        type: ActivityType.statusBooked,
      ),
      ActivityLogModel(
        id: 'act_3',
        description: 'A-103 details updated by Admin',
        actor: 'Admin',
        time: '11:45 AM',
        group: 'Today',
        type: ActivityType.unitUpdated,
      ),
      ActivityLogModel(
        id: 'act_4',
        description: 'New unit A-150 added in Royal City by Admin',
        actor: 'Admin',
        time: '12:10 PM',
        group: 'Today',
        type: ActivityType.unitAdded,
      ),
      ActivityLogModel(
        id: 'act_5',
        description: 'Price updated for 5 units in Royal City by Admin',
        actor: 'Admin',
        time: '04:20 PM',
        group: 'Yesterday',
        type: ActivityType.priceUpdated,
      ),
      ActivityLogModel(
        id: 'act_6',
        description: 'New marketing team XYZ Realtors onboarded by Admin',
        actor: 'Admin',
        time: '02:00 PM',
        group: 'Yesterday',
        type: ActivityType.unitAdded,
      ),
    ];
  }
}
