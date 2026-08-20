import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/syncr_badge.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'package:realestate_inventory/features/requests/data/models/block_request_model.dart';
import '../providers/requests_provider.dart';

class MyRequestsPage extends StatelessWidget {
  const MyRequestsPage({super.key});

  void _showRequestDetailsModal(BuildContext context, BlockRequestModel request) {
    final authProvider = context.read<AuthProvider>();
    final requestsProvider = context.read<RequestsProvider>();
    final isPromoterAdmin = authProvider.isPromoterAdmin;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Request Details',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SyncrBadge.fromStatus(request.status),
              ],
            ),
            const SizedBox(height: 16),
            _buildModalRow('Unit No.', request.unitNo),
            _buildModalRow('Project', request.projectName),
            _buildModalRow('Dimensions / Area', '${request.areaSqFt} sq.ft (${request.facing})'),
            _buildModalRow('Road Width', request.roadWidth),
            _buildModalRow('Price', request.formattedPrice),
            const Divider(height: 24, color: AppColors.borderLight),
            _buildModalRow('Customer Name', request.customerName),
            _buildModalRow('Customer Phone', request.customerPhone),
            if (request.customerEmail != null)
              _buildModalRow('Customer Email', request.customerEmail!),
            _buildModalRow('Booking Date', request.expectedBookingDate),
            if (request.remarks != null)
              _buildModalRow('Remarks', request.remarks!),
            const SizedBox(height: 24),

            if (isPromoterAdmin && request.status == 'Pending') ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        requestsProvider.reviewRequest(request.id, 'Rejected');
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Request rejected')),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.rejected,
                        side: const BorderSide(color: AppColors.rejected),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'Reject',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        requestsProvider.reviewRequest(request.id, 'Approved');
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: AppColors.available,
                            content: Text('Request approved successfully!'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.available,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      child: Text(
                        'Approve',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Close'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildModalRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
          ),
          Flexible(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final requestsProvider = context.watch<RequestsProvider>();
    final isRoot = ModalRoute.of(context)?.canPop != true;
    final requests = requestsProvider.filteredRequests;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: isRoot
            ? Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
        title: Text(
          'My Requests',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter Tabs Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTab(
                    context,
                    label: 'All (${requestsProvider.countAll})',
                    tab: 'All',
                    isSelected: requestsProvider.selectedTab == 'All',
                  ),
                  const SizedBox(width: 8),
                  _buildTab(
                    context,
                    label: 'Pending (${requestsProvider.countPending})',
                    tab: 'Pending',
                    isSelected: requestsProvider.selectedTab == 'Pending',
                    activeColor: AppColors.pending,
                  ),
                  const SizedBox(width: 8),
                  _buildTab(
                    context,
                    label: 'Approved (${requestsProvider.countApproved})',
                    tab: 'Approved',
                    isSelected: requestsProvider.selectedTab == 'Approved',
                    activeColor: AppColors.available,
                  ),
                  const SizedBox(width: 8),
                  _buildTab(
                    context,
                    label: 'Rejected (${requestsProvider.countRejected})',
                    tab: 'Rejected',
                    isSelected: requestsProvider.selectedTab == 'Rejected',
                    activeColor: AppColors.rejected,
                  ),
                ],
              ),
            ),
          ),

          // Requests List
          Expanded(
            child: requests.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_outlined,
                          size: 56,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No requests found',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Submitted block requests will show up here',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final req = requests[index];

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
                          onTap: () => _showRequestDetailsModal(context, req),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Top Row: Unit No & Status Pill
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      req.unitNo,
                                      style: GoogleFonts.poppins(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    SyncrBadge.fromStatus(req.status),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // Specs
                                Text(
                                  '${req.areaSqFt} sq.ft  •  ${req.facing}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),

                                // Date Info
                                Text(
                                  '${req.status == 'Pending' ? 'Request on' : req.status == 'Approved' ? 'Approved on' : 'Rejected on'} ${req.requestedDate}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 10),

                                // Customer Name & Chevron
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        text: 'Customer: ',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: AppColors.textSecondary,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: req.customerName,
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
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
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(
    BuildContext context, {
    required String label,
    required String tab,
    required bool isSelected,
    Color? activeColor,
  }) {
    return InkWell(
      onTap: () {
        context.read<RequestsProvider>().setSelectedTab(tab);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (activeColor != null ? activeColor.withValues(alpha: 0.12) : AppColors.primary)
              : AppColors.background,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected
                ? (activeColor ?? Colors.white)
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
