import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/syncr_badge.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../requests/presentation/pages/request_to_block_page.dart';
import 'package:realestate_inventory/features/inventory/data/models/unit_model.dart';
import '../providers/inventory_provider.dart';
import 'add_edit_unit_page.dart';

class UnitDetailsPage extends StatelessWidget {
  final UnitModel unit;

  const UnitDetailsPage({
    super.key,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final inventoryProvider = context.watch<InventoryProvider>();
    final authProvider = context.watch<AuthProvider>();
    final isAdmin = authProvider.isAdmin;

    // Get live unit model from provider if updated
    final liveUnit = inventoryProvider.units.firstWhere(
      (u) => u.id == unit.id,
      orElse: () => unit,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          liveUnit.unitNo,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              liveUnit.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: liveUnit.isFavorite ? const Color(0xFFEF4444) : AppColors.textPrimary,
            ),
            onPressed: () {
              inventoryProvider.toggleFavorite(liveUnit.id);
            },
          ),
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.textPrimary),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddEditUnitPage(unitToEdit: liveUnit),
                  ),
                );
              },
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Plot Visual
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        Image.network(
                          'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=800&auto=format&fit=crop&q=80',
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 200,
                            color: AppColors.primarySurface,
                            child: const Center(
                              child: Icon(Icons.landscape_rounded, size: 64, color: AppColors.primary),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 14,
                          left: 14,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Plot Layout View',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Unit Title & Status Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        liveUnit.unitNo,
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SyncrBadge.fromStatus(liveUnit.status),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Project Location
                  Text(
                    '${liveUnit.projectName}, Coimbatore',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 4 Feature Chips (Area, Road, Facing, Plot Type)
                  Row(
                    children: [
                      Expanded(
                        child: _buildFeatureTile(
                          icon: Icons.crop_square_rounded,
                          label: '${liveUnit.areaSqFt} sq.ft',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildFeatureTile(
                          icon: Icons.alt_route_rounded,
                          label: '${liveUnit.roadWidthFt ?? 30} ft Road',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildFeatureTile(
                          icon: Icons.explore_outlined,
                          label: liveUnit.facing ?? '',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildFeatureTile(
                          icon: Icons.grid_view_rounded,
                          label: liveUnit.plotType.replaceAll(' Plot', ''),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Pricing Section
                  Text(
                    'Pricing',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow('Total Price', liveUnit.formattedPrice, isBold: true),
                  const Divider(height: 20, color: AppColors.borderLight),
                  _buildDetailRow('Price per sq.ft', liveUnit.formattedPricePerSqFt),
                  const SizedBox(height: 24),

                  // Details Section
                  Text(
                    'Details',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow('Plot Type', liveUnit.plotType),
                  const Divider(height: 20, color: AppColors.borderLight),
                  _buildDetailRow('Dimensions', liveUnit.dimensions ?? ''),
                  const Divider(height: 20, color: AppColors.borderLight),
                  _buildDetailRow('Approval', liveUnit.approvalDetails ?? ''),

                  if (liveUnit.remarks != null && liveUnit.remarks!.isNotEmpty) ...[
                    const Divider(height: 20, color: AppColors.borderLight),
                    _buildDetailRow('Remarks', liveUnit.remarks!),
                  ],
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

          // Sticky Bottom Action Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: const Border(top: BorderSide(color: AppColors.borderLight)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Sharing details for ${liveUnit.unitNo}...'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.share_outlined, size: 18),
                      label: Text(
                        'Share',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.border),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: ElevatedButton(
                      onPressed: liveUnit.status == 'Booked' || liveUnit.status == 'Registered'
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RequestToBlockPage(unit: liveUnit),
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        liveUnit.status == 'Blocked' ? 'Re-Request Block' : 'Request to Block',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureTile({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColors.iconColor),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
