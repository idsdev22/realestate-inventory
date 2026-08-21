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
    final statusLower = unit.status.toLowerCase().trim();
    final isBooked = statusLower == 'booked' || statusLower == 'approved';
    final hasBookingRequest =
        unit.hasBookingRequest ||
        (unit.customerName != null &&
            unit.customerName!.trim().isNotEmpty &&
            (statusLower == 'available' ||
                statusLower == 'on_hold' ||
                statusLower == 'on hold'));

    // Status to display in top badge
    final displayStatus = isBooked
        ? 'Booked'
        : (hasBookingRequest ||
              statusLower == 'available' ||
              statusLower == 'on_hold' ||
              statusLower == 'on hold')
        ? 'Available'
        : unit.status;

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
                  Row(children: [SyncrBadge.fromStatus(displayStatus)]),
                ],
              ),
              const SizedBox(height: 10),

              // Middle Row: Specs
              Text(
                '${unit.areaSqFt} sq.ft  •  ${unit.facing ?? 'East Facing'}',
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

              // Request to Book Information Card (When Available with Request)
              if (hasBookingRequest && !isBooked) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB), // Warm amber tint
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFFDE68A),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.bookmark_added_outlined,
                            size: 14,
                            color: Color(0xFFD97706),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Request to Book',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFB45309),
                            ),
                          ),
                          if (unit.expectedBookingDate != null &&
                              unit.expectedBookingDate!.trim().isNotEmpty) ...[
                            const Spacer(),
                            const Icon(
                              Icons.event_outlined,
                              size: 12,
                              color: Color(0xFFB45309),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              unit.expectedBookingDate!,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFFB45309),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (unit.customerName != null &&
                          unit.customerName!.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.person_outline_rounded,
                              size: 13,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  text: 'Customer: ',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: unit.customerName!,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              // Booked Customer Information (When Booked)
              if (isBooked &&
                  unit.customerName != null &&
                  unit.customerName!.trim().isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF), // Soft blue tint
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFBFDBFE),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline_rounded,
                        size: 14,
                        color: Color(0xFF2563EB),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            text: 'Booked for: ',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: const Color(0xFF1E40AF),
                            ),
                            children: [
                              TextSpan(
                                text: unit.customerName!,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1E3A8A),
                                ),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

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
