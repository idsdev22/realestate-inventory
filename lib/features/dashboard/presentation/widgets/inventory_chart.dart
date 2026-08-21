import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../data/models/dashboard_model.dart';

class InventoryChart extends StatefulWidget {
  final DashboardChartsModel? chartsData;
  final InventorySummary? inventorySummary;

  const InventoryChart({super.key, this.chartsData, this.inventorySummary});

  @override
  State<InventoryChart> createState() => _InventoryChartState();
}

class _InventoryChartState extends State<InventoryChart> {
  int touchedIndex = -1;

  List<StatusPieItem> _getDisplayItems() {
    if (widget.chartsData != null && widget.chartsData!.statusPie.isNotEmpty) {
      return widget.chartsData!.statusPie;
    }

    // Default fallback from inventory summary if status_pie is empty
    final inv = widget.inventorySummary;
    final available = inv?.available ?? 6;
    final registered = inv?.registered ?? 3;
    final booked = inv?.booked ?? 4;
    final onHold = inv?.onHold ?? 2;

    return [
      StatusPieItem(
        status: 'Available',
        count: available.toDouble(),
        color: const Color(0xFF10B981),
      ),
      StatusPieItem(
        status: 'Registered',
        count: registered.toDouble(),
        color: const Color(0xFF8B5CF6),
      ),
      StatusPieItem(
        status: 'Booked',
        count: booked.toDouble(),
        color: const Color(0xFF3B82F6),
      ),
      StatusPieItem(
        status: 'On Hold',
        count: onHold.toDouble(),
        color: const Color(0xFFF59E0B),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final items = _getDisplayItems();
    final totalCount = items.fold<double>(0, (sum, item) => sum + item.count);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            offset: const Offset(0, 4),
            blurRadius: 16,
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Inventory Status Breakdown',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Real-time units distribution',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E88E5).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${totalCount.toInt()} Units Total',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E88E5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: totalCount == 0
                ? const Center(
                    child: Text(
                      'No inventory status data available',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: PieChart(
                          PieChartData(
                            pieTouchData: PieTouchData(
                              touchCallback: (event, pieTouchResponse) {
                                setState(() {
                                  if (!event.isInterestedForInteractions ||
                                      pieTouchResponse == null ||
                                      pieTouchResponse.touchedSection == null) {
                                    touchedIndex = -1;
                                    return;
                                  }
                                  touchedIndex = pieTouchResponse
                                      .touchedSection!
                                      .touchedSectionIndex;
                                });
                              },
                            ),
                            borderData: FlBorderData(show: false),
                            sectionsSpace: 3,
                            centerSpaceRadius: 40,
                            sections: List.generate(items.length, (i) {
                              final isTouched = i == touchedIndex;
                              final fontSize = isTouched ? 16.0 : 12.0;
                              final radius = isTouched ? 54.0 : 46.0;
                              final item = items[i];
                              final percentage = totalCount > 0
                                  ? ((item.count / totalCount) * 100)
                                        .toStringAsFixed(0)
                                  : '0';

                              return PieChartSectionData(
                                color: item.color,
                                value: item.count,
                                title: '$percentage%',
                                radius: radius,
                                titleStyle: TextStyle(
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 4,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: items.map((item) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: item.color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item.status,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF334155),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    item.count.toInt().toString(),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
