import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/syncr_badge.dart';
import '../../data/models/block_request_model.dart';
import '../providers/all_requests_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class AllRequestsPage extends StatefulWidget {
  const AllRequestsPage({super.key});

  @override
  State<AllRequestsPage> createState() => _AllRequestsPageState();
}

class _AllRequestsPageState extends State<AllRequestsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AllRequestsProvider>().fetchRequests(refresh: true);
    });
    
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        context.read<AllRequestsProvider>().fetchRequests();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showRequestDetailsModal(BuildContext context, BlockRequestModel request) {
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
            Consumer<AuthProvider>(
              builder: (context, auth, child) {
                if (!auth.isAdmin) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Close'),
                    ),
                  );
                }

                return Column(
                  children: [
                    if (request.status.toLowerCase() == 'pending') ...[
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                final success = await context.read<AllRequestsProvider>().reviewRequest(request.id, 'rejected');
                                if (success && ctx.mounted) Navigator.pop(ctx);
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.rejected,
                                side: const BorderSide(color: AppColors.rejected),
                              ),
                              child: const Text('Reject'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final success = await context.read<AllRequestsProvider>().reviewRequest(request.id, 'approved');
                                if (success && ctx.mounted) Navigator.pop(ctx);
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.available),
                              child: const Text('Approve'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                const SnackBar(content: Text('Edit feature coming soon')),
                              );
                            },
                            icon: const Icon(Icons.edit, size: 18, color: Colors.white),
                            label: const Text('Edit', style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final success = await context.read<AllRequestsProvider>().deleteRequest(request.id);
                              if (success && ctx.mounted) Navigator.pop(ctx);
                            },
                            icon: const Icon(Icons.delete, size: 18, color: Colors.white),
                            label: const Text('Delete', style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.rejected),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Close'),
                      ),
                    ),
                  ],
                );
              },
            ),
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
    final provider = context.watch<AllRequestsProvider>();
    final requests = provider.requests;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'All Requests',
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
                    label: 'All',
                    tab: 'All',
                    isSelected: provider.selectedTab == 'All',
                  ),
                  const SizedBox(width: 8),
                  _buildTab(
                    context,
                    label: 'Pending',
                    tab: 'Pending',
                    isSelected: provider.selectedTab == 'Pending',
                    activeColor: AppColors.pending,
                  ),
                  const SizedBox(width: 8),
                  _buildTab(
                    context,
                    label: 'Approved',
                    tab: 'Approved',
                    isSelected: provider.selectedTab == 'Approved',
                    activeColor: AppColors.available,
                  ),
                  const SizedBox(width: 8),
                  _buildTab(
                    context,
                    label: 'Rejected',
                    tab: 'Rejected',
                    isSelected: provider.selectedTab == 'Rejected',
                    activeColor: AppColors.rejected,
                  ),
                ],
              ),
            ),
          ),

          if (provider.errorMessage != null && requests.isEmpty)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AppColors.rejected, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        provider.errorMessage!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(color: AppColors.rejected),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => provider.fetchRequests(refresh: true),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (requests.isEmpty && !provider.isLoading)
            Expanded(
              child: Center(
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
              ),
            )
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => provider.fetchRequests(refresh: true),
                color: AppColors.primary,
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  itemCount: requests.length + (provider.isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == requests.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                      );
                    }

                    final req = requests[index];
                    return _buildRequestCard(context, req);
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, BlockRequestModel req) {
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
        context.read<AllRequestsProvider>().setSelectedTab(tab);
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
