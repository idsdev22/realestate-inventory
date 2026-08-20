import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../features/inventory/data/models/unit_model.dart';
import '../theme/app_theme.dart';
import 'syncr_badge.dart';

class UnitCard extends StatelessWidget {
  final UnitModel unit;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onFavoriteToggle;
  final bool isSelected;
  final bool isSelectionMode;
  final bool showFavorite;

  const UnitCard({
    super.key,
    required this.unit,
    required this.onTap,
    this.onLongPress,
    this.onFavoriteToggle,
    this.isSelected = false,
    this.isSelectionMode = false,
    this.showFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primarySurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.borderLight,
          width: isSelected ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Unit No & Status Badge & Trailing icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (isSelectionMode) ...[
                        Checkbox(
                          value: isSelected,
                          onChanged: (_) => onTap(),
                          activeColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        unit.unitNo,
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Row(children: [SyncrBadge.fromStatus(unit.status)]),
                ],
              ),
              const SizedBox(height: 10),

              // Middle Row: Specs
              Text(
                '${unit.areaSqFt} sq.ft  •  ${unit.facing}',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${unit.roadWidthFt ?? 30} ft Road',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 12),

              // Bottom Row: Price & Action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    unit.formattedPrice,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (!isSelectionMode && !showFavorite)
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.iconColor,
                      size: 22,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
