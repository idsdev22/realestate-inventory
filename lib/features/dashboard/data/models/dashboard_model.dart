import 'package:flutter/material.dart';

class InventorySummary {
  final int available;
  final int booked;
  final int blocked;
  final int total;

  InventorySummary({
    this.available = 0,
    this.booked = 0,
    this.blocked = 0,
    this.total = 0,
  });

  factory InventorySummary.fromJson(Map<String, dynamic> json) {
    final available = _parseInt(json['available']);
    final booked = _parseInt(json['booked']);
    final blocked = _parseInt(json['blocked']);
    final total = _parseInt(json['total']) != 0
        ? _parseInt(json['total'])
        : (available + booked + blocked);

    return InventorySummary(
      available: available,
      booked: booked,
      blocked: blocked,
      total: total,
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

class DashboardModel {
  final int totalProjects;
  final InventorySummary inventory;

  DashboardModel({
    required this.totalProjects,
    required this.inventory,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    final totalProjects = json['total_projects'] is int
        ? json['total_projects'] as int
        : (int.tryParse(json['total_projects']?.toString() ?? '0') ?? 0);

    final inventoryMap = json['inventory'] is Map<String, dynamic>
        ? json['inventory'] as Map<String, dynamic>
        : <String, dynamic>{};

    return DashboardModel(
      totalProjects: totalProjects,
      inventory: InventorySummary.fromJson(inventoryMap),
    );
  }
}

class StatusPieItem {
  final String status;
  final double count;
  final Color color;

  StatusPieItem({
    required this.status,
    required this.count,
    required this.color,
  });

  factory StatusPieItem.fromJson(Map<String, dynamic> json, int index) {
    final status = json['status']?.toString() ?? 'Unknown';
    final count = (json['count'] is num)
        ? (json['count'] as num).toDouble()
        : (double.tryParse(json['count']?.toString() ?? '0') ?? 0.0);

    final colorHex = json['color']?.toString();
    Color color;
    if (colorHex != null && colorHex.startsWith('#')) {
      final hex = colorHex.replaceFirst('#', '');
      color = Color(int.parse('FF$hex', radix: 16));
    } else {
      final fallbackColors = [
        const Color(0xFF1E88E5), // Blue
        const Color(0xFF43A047), // Green
        const Color(0xFFFB8C00), // Amber
        const Color(0xFFE53935), // Red
        const Color(0xFF8E24AA), // Purple
      ];
      color = fallbackColors[index % fallbackColors.length];
    }

    return StatusPieItem(
      status: status,
      count: count,
      color: color,
    );
  }
}

class DashboardChartsModel {
  final List<StatusPieItem> statusPie;

  DashboardChartsModel({
    required this.statusPie,
  });

  factory DashboardChartsModel.fromJson(Map<String, dynamic> json) {
    final rawList = json['status_pie'];
    final List<StatusPieItem> items = [];

    if (rawList is List) {
      for (int i = 0; i < rawList.length; i++) {
        final item = rawList[i];
        if (item is Map<String, dynamic>) {
          items.add(StatusPieItem.fromJson(item, i));
        }
      }
    }

    return DashboardChartsModel(statusPie: items);
  }
}
