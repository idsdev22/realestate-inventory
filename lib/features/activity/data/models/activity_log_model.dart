import 'package:flutter/material.dart';

enum ActivityType {
  statusBlocked,
  statusBooked,
  unitUpdated,
  unitAdded,
  priceUpdated,
}

class ActivityLogModel {
  final String id;
  final String description;
  final String actor;
  final String time;
  final String group; // 'Today', 'Yesterday', etc.
  final ActivityType type;

  ActivityLogModel({
    required this.id,
    required this.description,
    required this.actor,
    required this.time,
    required this.group,
    required this.type,
  });

  Color get iconColor {
    switch (type) {
      case ActivityType.statusBlocked:
        return const Color(0xFFF59E0B);
      case ActivityType.statusBooked:
        return const Color(0xFF3B82F6);
      case ActivityType.unitUpdated:
        return const Color(0xFF10B981);
      case ActivityType.unitAdded:
        return const Color(0xFF8B5CF6);
      case ActivityType.priceUpdated:
        return const Color(0xFF10B981);
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
        return Icons.add_home_rounded;
      case ActivityType.priceUpdated:
        return Icons.currency_rupee_rounded;
    }
  }
}
