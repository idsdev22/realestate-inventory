import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum ActivityType {
  statusBlocked,
  statusBooked,
  unitUpdated,
  unitAdded,
  priceUpdated,
  itemDeleted,
  itemAdded,
  other,
}

class ActivityLogModel {
  final int id;
  final int? userId;
  final int? companyId;
  final String? userName;
  final String action;
  final String? entityType;
  final int? entityId;
  final String description;
  final dynamic meta;
  final String? ipAddress;
  final DateTime createdAt;

  ActivityLogModel({
    required this.id,
    this.userId,
    this.companyId,
    this.userName,
    required this.action,
    this.entityType,
    this.entityId,
    required this.description,
    this.meta,
    this.ipAddress,
    required this.createdAt,
  });

  factory ActivityLogModel.fromJson(Map<String, dynamic> json) {
    return ActivityLogModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      userId: json['user_id'] != null
          ? (json['user_id'] is int
                ? json['user_id']
                : int.tryParse(json['user_id'].toString()))
          : null,
      companyId: json['company_id'] != null
          ? (json['company_id'] is int
                ? json['company_id']
                : int.tryParse(json['company_id'].toString()))
          : null,
      userName:
          json['user_name']?.toString() ??
          json['userName']?.toString() ??
          (json['user'] != null && json['user'] is Map
              ? json['user']['name']
              : null),
      action: json['action']?.toString() ?? '',
      entityType: json['entity_type']?.toString(),
      entityId: json['entity_id'] != null
          ? (json['entity_id'] is int
                ? json['entity_id']
                : int.tryParse(json['entity_id'].toString()))
          : null,
      description: json['description']?.toString() ?? '',
      meta: json['meta'],
      ipAddress: json['ip_address']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  // UI Helpers
  String get actor {
    return userName?.isNotEmpty == true ? userName! : 'User';
  }

  String get time {
    return DateFormat('hh:mm a').format(createdAt);
  }

  String get group {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final activityDate = DateTime(
      createdAt.year,
      createdAt.month,
      createdAt.day,
    );

    if (activityDate == today) {
      return 'Today';
    } else if (activityDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('dd MMM yyyy').format(createdAt);
    }
  }

  ActivityType get type {
    final lowerAction = action.toLowerCase();
    if (lowerAction.contains('blocked')) return ActivityType.statusBlocked;
    if (lowerAction.contains('booked')) return ActivityType.statusBooked;
    if (lowerAction.contains('unit_added') ||
        lowerAction.contains('unit added'))
      return ActivityType.unitAdded;
    if (lowerAction.contains('price')) return ActivityType.priceUpdated;
    if (lowerAction.contains('delete')) return ActivityType.itemDeleted;
    if (lowerAction.contains('add') || lowerAction.contains('create'))
      return ActivityType.itemAdded;
    if (lowerAction.contains('unit_updated') ||
        lowerAction.contains('unit updated') ||
        lowerAction.contains('update'))
      return ActivityType.unitUpdated;
    return ActivityType.other;
  }

  Color get iconColor {
    switch (type) {
      case ActivityType.statusBlocked:
        return const Color(0xFFF59E0B);
      case ActivityType.statusBooked:
        return const Color(0xFF3B82F6);
      case ActivityType.unitUpdated:
        return const Color(0xFF10B981);
      case ActivityType.unitAdded:
      case ActivityType.itemAdded:
        return const Color(0xFF8B5CF6);
      case ActivityType.priceUpdated:
        return const Color(0xFF10B981);
      case ActivityType.itemDeleted:
        return const Color(0xFFEF4444);
      case ActivityType.other:
        return const Color(0xFF6B7280);
    }
  }

  IconData get iconData {
    switch (type) {
      case ActivityType.statusBlocked:
        return Icons.radio_button_checked_rounded;
      case ActivityType.statusBooked:
        return Icons.bookmark_added_rounded;
      case ActivityType.unitUpdated:
        return Icons.edit_note_rounded;
      case ActivityType.unitAdded:
      case ActivityType.itemAdded:
        return Icons.add_home_rounded;
      case ActivityType.priceUpdated:
        return Icons.currency_rupee_rounded;
      case ActivityType.itemDeleted:
        return Icons.delete_outline_rounded;
      case ActivityType.other:
        return Icons.local_activity_rounded;
    }
  }
}
