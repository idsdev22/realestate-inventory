import 'package:flutter/material.dart';

class MarketingTeamModel {
  final String id;
  final String name;
  final String email;
  final int userCount;
  final int projectCount;
  final String status; // 'Active' or 'Inactive'
  final Color avatarBgColor;

  MarketingTeamModel({
    required this.id,
    required this.name,
    required this.email,
    required this.userCount,
    required this.projectCount,
    this.status = 'Active',
    this.avatarBgColor = const Color(0xFF5C54E5),
  });

  MarketingTeamModel copyWith({
    String? id,
    String? name,
    String? email,
    int? userCount,
    int? projectCount,
    String? status,
    Color? avatarBgColor,
  }) {
    return MarketingTeamModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      userCount: userCount ?? this.userCount,
      projectCount: projectCount ?? this.projectCount,
      status: status ?? this.status,
      avatarBgColor: avatarBgColor ?? this.avatarBgColor,
    );
  }
}

class UserMemberModel {
  final String id;
  final String name;
  final String role; // 'Team Admin', 'Sales Executive', etc.
  final String email;
  final Color avatarBgColor;
  final String initial;

  UserMemberModel({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
    required this.avatarBgColor,
    required this.initial,
  });

  UserMemberModel copyWith({
    String? id,
    String? name,
    String? role,
    String? email,
    Color? avatarBgColor,
    String? initial,
  }) {
    return UserMemberModel(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      email: email ?? this.email,
      avatarBgColor: avatarBgColor ?? this.avatarBgColor,
      initial: initial ?? this.initial,
    );
  }
}
