import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../features/projects/data/models/project_model.dart';
import '../theme/app_theme.dart';
import 'syncr_badge.dart';

class ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback onTap;
  final bool showTotalUnits;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
    this.showTotalUnits = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
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
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Project Image Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  project.imageUrl,
                  width: 76,
                  height: 76,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 76,
                      height: 76,
                      color: AppColors.primaryLight,
                      child: const Icon(
                        Icons.apartment_rounded,
                        color: AppColors.primary,
                        size: 36,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 14),

              // Project Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      project.location,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.normal,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (showTotalUnits) ...[
                          Text(
                            'Total Units: ${project.totalUnits}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '•',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                          ),
                          const SizedBox(width: 8),
                        ],
                        SyncrBadge(
                          label: '${project.availableUnits} Available',
                          type: SyncrBadgeType.available,
                          fontSize: 11,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Chevron Icon
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.iconColor,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
