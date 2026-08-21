import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

enum SyncrBadgeType {
  available,
  booked,
  registered,
  onHold,
  pending,
  approved,
  rejected,
  active,
  inactive,
  custom,
}

class SyncrBadge extends StatelessWidget {
  final String label;
  final SyncrBadgeType type;
  final Color? customBgColor;
  final Color? customTextColor;
  final bool showDot;
  final double fontSize;
  final EdgeInsetsGeometry? padding;

  const SyncrBadge({
    super.key,
    required this.label,
    this.type = SyncrBadgeType.available,
    this.customBgColor,
    this.customTextColor,
    this.showDot = false,
    this.fontSize = 12,
    this.padding,
  });

  factory SyncrBadge.fromStatus(String status, {bool showDot = false}) {
    final lower = status.toLowerCase().trim();
    SyncrBadgeType badgeType = SyncrBadgeType.custom;
    String displayLabel = status;

    if (lower == 'available') {
      badgeType = SyncrBadgeType.available;
      displayLabel = 'Available';
    } else if (lower == 'booked') {
      badgeType = SyncrBadgeType.booked;
      displayLabel = 'Booked';
    } else if (lower == 'registered') {
      badgeType = SyncrBadgeType.registered;
      displayLabel = 'Registered';
    } else if (lower == 'on_hold' || lower == 'on hold' || lower == 'onhold' || lower == 'hold' || lower == 'blocked') {
      badgeType = SyncrBadgeType.onHold;
      displayLabel = 'On Hold';
    } else if (lower == 'pending') {
      badgeType = SyncrBadgeType.pending;
      displayLabel = 'Pending';
    } else if (lower == 'approved') {
      badgeType = SyncrBadgeType.approved;
      displayLabel = 'Booked';
    } else if (lower == 'rejected') {
      badgeType = SyncrBadgeType.rejected;
      displayLabel = 'Rejected';
    } else if (lower == 'active') {
      badgeType = SyncrBadgeType.active;
      displayLabel = 'Active';
    } else if (lower == 'inactive') {
      badgeType = SyncrBadgeType.inactive;
      displayLabel = 'Inactive';
    }

    return SyncrBadge(
      label: displayLabel,
      type: badgeType,
      showDot: showDot,
    );
  }

  Color get _backgroundColor {
    if (customBgColor != null) return customBgColor!;
    switch (type) {
      case SyncrBadgeType.available:
      case SyncrBadgeType.active:
      case SyncrBadgeType.approved:
        return const Color(0xFFE8F8F0);
      case SyncrBadgeType.onHold:
      case SyncrBadgeType.pending:
        return const Color(0xFFFEF3E2);
      case SyncrBadgeType.booked:
        return const Color(0xFFEBF3FE);
      case SyncrBadgeType.registered:
        return const Color(0xFFF3EBFD);
      case SyncrBadgeType.rejected:
      case SyncrBadgeType.inactive:
        return const Color(0xFFFEECEB);
      case SyncrBadgeType.custom:
        return AppColors.borderLight;
    }
  }

  Color get _textColor {
    if (customTextColor != null) return customTextColor!;
    switch (type) {
      case SyncrBadgeType.available:
      case SyncrBadgeType.active:
      case SyncrBadgeType.approved:
        return const Color(0xFF10B981);
      case SyncrBadgeType.onHold:
      case SyncrBadgeType.pending:
        return const Color(0xFFF59E0B);
      case SyncrBadgeType.booked:
        return const Color(0xFF3B82F6);
      case SyncrBadgeType.registered:
        return const Color(0xFF8B5CF6);
      case SyncrBadgeType.rejected:
      case SyncrBadgeType.inactive:
        return const Color(0xFFEF4444);
      case SyncrBadgeType.custom:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: _textColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: _textColor,
            ),
          ),
        ],
      ),
    );
  }
}
