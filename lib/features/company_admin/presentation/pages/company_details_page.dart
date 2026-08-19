import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/syncr_badge.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/company_model.dart';
import '../providers/company_provider.dart';
import 'add_edit_company_page.dart';

class CompanyDetailsPage extends StatefulWidget {
  final int companyId;
  final CompanyModel? initialCompany;

  const CompanyDetailsPage({
    super.key,
    required this.companyId,
    this.initialCompany,
  });

  @override
  State<CompanyDetailsPage> createState() => _CompanyDetailsPageState();
}

class _CompanyDetailsPageState extends State<CompanyDetailsPage> {
  late CompanyModel _company;

  @override
  void initState() {
    super.initState();
    if (widget.initialCompany != null) {
      _company = widget.initialCompany!;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CompanyProvider>().fetchCompanyById(widget.companyId);
    });
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    if (!auth.isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only Promoter Admins can delete marketing companies.'),
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
          'Are you sure you want to delete "${_company.name}"? This action will revoke all access for their sales staff.',
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
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.rejected,
              elevation: 0,
            ),
            child: Text(
              'Delete Company',
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final provider = context.read<CompanyProvider>();
      final success = await provider.deleteCompany(_company.id ?? widget.companyId);
      if (!context.mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Company "${_company.name}" deleted.'),
            backgroundColor: AppColors.textPrimary,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Failed to delete company'),
            backgroundColor: AppColors.rejected,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final companyProvider = context.watch<CompanyProvider>();
    final authProvider = context.watch<AuthProvider>();
    final isPromoterAdmin = authProvider.isAdmin;

    final company = companyProvider.selectedCompany ?? (widget.initialCompany ?? _company);
    _company = company;

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
          'Company Profile',
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          if (isPromoterAdmin) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primary),
              tooltip: 'Edit Company',
              onPressed: () async {
                final updated = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddEditCompanyPage(company: company),
                  ),
                );
                if (updated == true && context.mounted) {
                  companyProvider.fetchCompanyById(widget.companyId);
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.rejected),
              tooltip: 'Delete Company',
              onPressed: () => _confirmDelete(context),
            ),
          ],
        ],
      ),
      body: companyProvider.isLoading && companyProvider.selectedCompany == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => companyProvider.fetchCompanyById(widget.companyId),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Hero Card
                    _buildCompanyHeroCard(company),
                    const SizedBox(height: 18),

                    // Quick Stats Row
                    _buildStatsRow(company),
                    const SizedBox(height: 18),

                    // Contact Particulars Card
                    _buildContactCard(company),
                    const SizedBox(height: 18),

                    // Assigned Projects Card
                    _buildAssignedProjectsCard(company),
                    const SizedBox(height: 18),

                    // Permissions Matrix Card
                    _buildPermissionsCard(company),
                    const SizedBox(height: 30),

                    // Admin Actions (If Promoter Admin)
                    if (isPromoterAdmin) ...[
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final updated = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddEditCompanyPage(company: company),
                                  ),
                                );
                                if (updated == true && context.mounted) {
                                  companyProvider.fetchCompanyById(widget.companyId);
                                }
                              },
                              icon: const Icon(Icons.edit_rounded, size: 18, color: AppColors.primary),
                              label: Text(
                                'Edit Particulars',
                                style: GoogleFonts.poppins(color: AppColors.primary, fontSize: 13.5),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _confirmDelete(context),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.rejected),
                              ),
                              icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.rejected),
                              label: Text(
                                'Delete Agency',
                                style: GoogleFonts.poppins(color: AppColors.rejected, fontSize: 13.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCompanyHeroCard(CompanyModel company) {
    final initials = company.name.isNotEmpty
        ? company.name.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : 'MK';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company.name,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${company.city}, ${company.address}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.borderLight),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SyncrBadge(
                label: company.isActive ? 'Active Agency' : 'Inactive / Suspended',
                type: company.isActive ? SyncrBadgeType.available : SyncrBadgeType.rejected,
              ),
              Text(
                'ID: #${company.id ?? widget.companyId}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(CompanyModel company) {
    return Row(
      children: [
        Expanded(
          child: _buildStatMiniCard(
            title: 'Assigned Projects',
            value: '${company.projectIds.length}',
            icon: Icons.apartment_rounded,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatMiniCard(
            title: 'Active Permissions',
            value: '${company.permissions.length}',
            icon: Icons.shield_outlined,
            color: AppColors.booked,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatMiniCard(
            title: 'Team Staff',
            value: '${company.userCount ?? 6}',
            icon: Icons.people_alt_rounded,
            color: AppColors.available,
          ),
        ),
      ],
    );
  }

  Widget _buildStatMiniCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 10.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(CompanyModel company) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.contact_mail_outlined, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                'Contact Information',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.borderLight),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.email_outlined, 'Email Address', company.email),
          const SizedBox(height: 10),
          _buildInfoRow(Icons.phone_outlined, 'Phone Number', company.phone),
          const SizedBox(height: 10),
          _buildInfoRow(Icons.location_city_rounded, 'City', company.city),
          const SizedBox(height: 10),
          _buildInfoRow(Icons.pin_drop_outlined, 'Address / Office', company.address),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.textMuted, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary),
              ),
              Text(
                value.isNotEmpty ? value : '—',
                style: GoogleFonts.poppins(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAssignedProjectsCard(CompanyModel company) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.apartment_rounded, color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Assigned Projects',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Text(
                '${company.projectIds.length} Projects',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.borderLight),
          const SizedBox(height: 14),
          if (company.projectIds.isEmpty)
            Text(
              'No projects currently assigned to this company.',
              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: company.projectIds.map((id) {
                final name = (company.projectNames != null &&
                        company.projectNames!.isNotEmpty &&
                        company.projectIds.indexOf(id) < company.projectNames!.length)
                    ? company.projectNames![company.projectIds.indexOf(id)]
                    : 'Project #$id (Royal City)';
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primaryLight),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        name,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildPermissionsCard(CompanyModel company) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_outlined, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                'Access Permissions Matrix',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.borderLight),
          const SizedBox(height: 12),
          ...CompanyModel.availablePermissions.map((perm) {
            final key = perm['key']!;
            final label = perm['label']!;
            final desc = perm['description']!;
            final isEnabled = company.hasPermission(key);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Row(
                children: [
                  Icon(
                    isEnabled ? Icons.check_circle_rounded : Icons.cancel_outlined,
                    color: isEnabled ? AppColors.available : AppColors.textMuted,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: isEnabled ? FontWeight.w600 : FontWeight.normal,
                            color: isEnabled ? AppColors.textPrimary : AppColors.textMuted,
                          ),
                        ),
                        Text(
                          desc,
                          style: GoogleFonts.poppins(
                            fontSize: 10.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SyncrBadge(
                    label: isEnabled ? 'Enabled' : 'Disabled',
                    type: isEnabled ? SyncrBadgeType.available : SyncrBadgeType.rejected,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
