import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/syncr_badge.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/company_model.dart';
import '../providers/company_provider.dart';
import 'add_edit_company_page.dart';
import 'company_details_page.dart';

class CompaniesListPage extends StatefulWidget {
  const CompaniesListPage({super.key});

  @override
  State<CompaniesListPage> createState() => _CompaniesListPageState();
}

class _CompaniesListPageState extends State<CompaniesListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CompanyProvider>().fetchCompanies();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    context.read<CompanyProvider>().setSearchQuery(query);
  }

  Future<void> _deleteCompany(CompanyModel company) async {
    final auth = context.read<AuthProvider>();
    if (!auth.isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Access Denied: Only Promoter Admins can delete marketing companies.'),
          backgroundColor: AppColors.rejected,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Marketing Company?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        content: Text(
          'Are you sure you want to delete "${company.name}"? This action cannot be undone.',
          style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.rejected, elevation: 0),
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<CompanyProvider>().deleteCompany(company.id ?? 0);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Company "${company.name}" deleted successfully.'),
              backgroundColor: AppColors.textPrimary,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete company.'),
              backgroundColor: AppColors.rejected,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final companyProvider = context.watch<CompanyProvider>();
    final authProvider = context.watch<AuthProvider>();
    final isPromoterAdmin = authProvider.isAdmin;
    final filteredCompanies = companyProvider.filteredCompanies;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Marketing Companies',
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          if (isPromoterAdmin)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: const Icon(Icons.add_business_rounded, color: AppColors.primary),
                tooltip: 'Add Marketing Company',
                onPressed: () => _navigateToAddCompany(context),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => companyProvider.fetchCompanies(),
        child: Column(
          children: [
            // Top Search and Stats Section
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              color: Colors.white,
              child: Column(
                children: [
                  // Role Badge Banner if Promoter Admin
                  if (isPromoterAdmin)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.primaryLight),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.verified_user_rounded, color: AppColors.primary, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Promoter Admin Mode: Full company management authorized.',
                              style: GoogleFonts.poppins(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Search Bar
                  TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    style: GoogleFonts.poppins(fontSize: 13.5),
                    decoration: InputDecoration(
                      hintText: 'Search by company name, city, email...',
                      prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.iconColor),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Filter Chips & Stats
                  Row(
                    children: [
                      _buildFilterChip('All', 'all', companyProvider.totalCompanies),
                      const SizedBox(width: 8),
                      _buildFilterChip('Active', 'active', companyProvider.activeCompaniesCount),
                      const SizedBox(width: 8),
                      _buildFilterChip('Inactive', 'inactive', companyProvider.inactiveCompaniesCount),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.borderLight),

            // Companies List Content
            Expanded(
              child: companyProvider.isLoading && companyProvider.companies.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : filteredCompanies.isEmpty
                      ? _buildEmptyState(context, isPromoterAdmin)
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredCompanies.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final company = filteredCompanies[index];
                            return _buildCompanyCard(context, company, isPromoterAdmin);
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: isPromoterAdmin
          ? FloatingActionButton.extended(
              onPressed: () => _navigateToAddCompany(context),
              backgroundColor: AppColors.primary,
              elevation: 3,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: Text(
                'Add Company',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                  color: Colors.white,
                ),
              ),
            )
          : null,
    );
  }

  void _navigateToAddCompany(BuildContext ctx) async {
    final result = await Navigator.push<bool>(
      ctx,
      MaterialPageRoute(builder: (_) => const AddEditCompanyPage()),
    );
    if (result == true && mounted) {
      if (context.mounted) {
        context.read<CompanyProvider>().fetchCompanies();
      }
    }
  }

  Widget _buildFilterChip(String label, String value, int count) {
    final companyProvider = context.watch<CompanyProvider>();
    final isSelected = companyProvider.statusFilter == value;

    return InkWell(
      onTap: () => companyProvider.setStatusFilter(value),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.25)
                    : AppColors.primarySurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: GoogleFonts.poppins(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyCard(
    BuildContext context,
    CompanyModel company,
    bool isPromoterAdmin,
  ) {
    final initials = company.name.isNotEmpty
        ? company.name
            .trim()
            .split(' ')
            .map((e) => e.isNotEmpty ? e[0] : '')
            .take(2)
            .join()
            .toUpperCase()
        : 'MK';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CompanyDetailsPage(
                companyId: company.id ?? 1,
                initialCompany: company,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Avatar, Name, Status, Actions
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: company.isActive
                            ? [AppColors.primaryDark, AppColors.primary]
                            : [AppColors.textMuted, AppColors.border],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                company.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primarySurface,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                company.city,
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          company.email,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SyncrBadge(
                        label: company.isActive ? 'Active' : 'Inactive',
                        type: company.isActive
                            ? SyncrBadgeType.available
                            : SyncrBadgeType.rejected,
                      ),
                      if (isPromoterAdmin)
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert_rounded, size: 18, color: AppColors.textMuted),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          onSelected: (val) async {
                            if (val == 'edit') {
                              final res = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddEditCompanyPage(company: company),
                                ),
                              );
                              if (res == true && context.mounted) {
                                context.read<CompanyProvider>().fetchCompanies();
                              }
                            } else if (val == 'delete') {
                              _deleteCompany(company);
                            }
                          },
                          itemBuilder: (ctx) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined, size: 16, color: AppColors.primary),
                                  SizedBox(width: 8),
                                  Text('Edit Particulars', style: TextStyle(fontSize: 13)),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.rejected),
                                  SizedBox(width: 8),
                                  Text('Delete Agency', style: TextStyle(fontSize: 13, color: AppColors.rejected)),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: AppColors.borderLight),
              const SizedBox(height: 10),

              // Contact & Address Row
              Row(
                children: [
                  const Icon(Icons.phone_outlined, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    company.phone,
                    style: GoogleFonts.poppins(fontSize: 11.5, color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: 14),
                  const Icon(Icons.pin_drop_outlined, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      company.address,
                      style: GoogleFonts.poppins(fontSize: 11.5, color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Assigned Projects & Permissions Pills
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.apartment_rounded, size: 12, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          '${company.projectIds.length} Projects',
                          style: GoogleFonts.poppins(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...company.permissions.take(2).map((p) {
                    final label = p == 'view_inventory'
                        ? 'View Plots'
                        : p == 'submit_block_requests'
                            ? 'Block Requests'
                            : p == 'manage_users'
                                ? 'Manage Users'
                                : p;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.borderLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        label,
                        style: GoogleFonts.poppins(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  }),
                  if (company.permissions.length > 2)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.borderLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '+${company.permissions.length - 2} more',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isPromoterAdmin) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.business_outlined, color: AppColors.primary, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              'No Marketing Companies Found',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Create new marketing agency accounts to grant access to project inventories and allow block reservations.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            if (isPromoterAdmin) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _navigateToAddCompany(context),
                icon: const Icon(Icons.add_business_rounded, size: 18),
                label: const Text('Add Marketing Company'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
