import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../features/projects/data/models/project_model.dart';
import '../theme/app_theme.dart';
import 'syncr_badge.dart';

class ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showTotalUnits;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
    this.onEdit,
    this.onDelete,
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
                child: _buildCoverImage(project.imageUrl),
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
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        SyncrBadge(
                          label: '${project.availableUnits} Available',
                          type: SyncrBadgeType.available,
                          fontSize: 11,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Trailing Options / Chevron
              if (onEdit != null || onDelete != null)
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: AppColors.iconColor,
                    size: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (value) {
                    if (value == 'edit' && onEdit != null) {
                      onEdit!();
                    } else if (value == 'delete' && onDelete != null) {
                      onDelete!();
                    }
                  },
                  itemBuilder: (context) => [
                    if (onEdit != null)
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.edit_outlined,
                              size: 18,
                              color: AppColors.textPrimary,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Edit Project',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (onDelete != null)
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.delete_outline_rounded,
                              size: 18,
                              color: AppColors.rejected,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Delete Project',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: AppColors.rejected,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                )
              else
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

  Widget _buildCoverImage(String imageUrl) {
    final cleanUrl = ProjectModel.sanitizeImage(imageUrl) ?? imageUrl;
    Widget fallback = Container(
      width: 76,
      height: 76,
      color: AppColors.primaryLight,
      child: const Icon(
        Icons.apartment_rounded,
        color: AppColors.primary,
        size: 32,
      ),
    );

    if (cleanUrl.contains('data:image') || cleanUrl.contains(';base64,')) {
      try {
        final commaIndex = cleanUrl.indexOf(',');
        final base64String = commaIndex != -1
            ? cleanUrl.substring(commaIndex + 1)
            : cleanUrl;
        String cleanBase64 = base64String.replaceAll(RegExp(r'\s+'), '');
        if (cleanBase64.contains('%')) {
          cleanBase64 = Uri.decodeComponent(cleanBase64);
        }
        int padding = cleanBase64.length % 4;
        if (padding > 0) {
          cleanBase64 += '=' * (4 - padding);
        }
        return Image.memory(
          base64Decode(cleanBase64),
          width: 76,
          height: 76,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => fallback,
        );
      } catch (e) {
        return fallback;
      }
    }
    return Image.network(
      cleanUrl,
      width: 76,
      height: 76,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => fallback,
    );
  }
}
