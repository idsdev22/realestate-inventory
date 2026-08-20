import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/project_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../inventory/presentation/providers/inventory_provider.dart';

class AddEditProjectPage extends StatefulWidget {
  final ProjectModel? project;

  const AddEditProjectPage({super.key, this.project});

  @override
  State<AddEditProjectPage> createState() => _AddEditProjectPageState();
}

class _AddEditProjectPageState extends State<AddEditProjectPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _cityController;
  late TextEditingController _locationController;
  late TextEditingController _approvalController;
  late TextEditingController _descriptionController;

  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  String? _existingCoverImageUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.project?.name ?? '');
    _cityController = TextEditingController(text: widget.project?.city ?? '');
    _locationController = TextEditingController(
      text: widget.project?.location ?? '',
    );
    _approvalController = TextEditingController(
      text: widget.project?.approvalDetails ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.project?.description ?? '',
    );
    _existingCoverImageUrl = widget.project?.coverImage;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _locationController.dispose();
    _approvalController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = pickedFile;
          _existingCoverImageUrl = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.rejected,
            content: Text('Failed to pick image: $e'),
          ),
        );
      }
    }
  }

  void _saveProject() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isPromoterAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Access Denied: Only Promoter Admins can create or edit projects.',
          ),
          backgroundColor: AppColors.rejected,
        ),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      String? uploadedImageUrl = _existingCoverImageUrl;

      if (_selectedImage != null) {
        final bytes = await _selectedImage!.readAsBytes();
        final base64String = base64Encode(bytes);
        final extension = _selectedImage!.name.split('.').last.toLowerCase();
        final mimeType = extension == 'png'
            ? 'image/png'
            : (extension == 'webp' ? 'image/webp' : 'image/jpeg');
        uploadedImageUrl = 'data:$mimeType;base64,$base64String';
      }

      final newProject = ProjectModel(
        id:
            widget.project?.id ??
            DateTime.now().millisecondsSinceEpoch % 1000000,
        name: _nameController.text.trim(),
        city: _cityController.text.trim(),
        location: _locationController.text.trim(),
        approvalDetails: _approvalController.text.trim(),
        description: _descriptionController.text.trim(),
        status: widget.project?.status ?? 'active',
        coverImage: uploadedImageUrl,
      );

      final provider = context.read<InventoryProvider>();
      final success = widget.project != null
          ? await provider.updateProject(widget.project!.id, newProject)
          : await provider.addProject(newProject);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.available,
              content: Text('Project saved successfully!'),
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.rejected,
              content: Text('Failed to save project. Please try again.'),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          widget.project == null ? 'Add project' : 'Edit project',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFieldLabel('NAME'),
                _buildTextField(
                  controller: _nameController,
                  validator: (v) =>
                      v?.trim().isEmpty ?? true ? 'Enter project name' : null,
                ),
                const SizedBox(height: 24),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('CITY'),
                          _buildTextField(
                            controller: _cityController,
                            validator: (v) =>
                                v?.trim().isEmpty ?? true ? 'Enter city' : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('LOCATION'),
                          _buildTextField(
                            controller: _locationController,
                            validator: (v) => v?.trim().isEmpty ?? true
                                ? 'Enter location'
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                _buildFieldLabel('APPROVAL'),
                _buildTextField(controller: _approvalController),
                const SizedBox(height: 24),

                _buildFieldLabel('DESCRIPTION'),
                _buildTextField(
                  controller: _descriptionController,
                  maxLines: 4,
                ),
                const SizedBox(height: 24),

                _buildFieldLabel('COVER IMAGE'),
                Text(
                  'JPG, PNG or WEBP · max 4 MB',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 160,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.borderLight,
                      width: 1.5,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _selectedImage != null
                      ? (kIsWeb
                            ? Image.network(
                                _selectedImage!.path,
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                File(_selectedImage!.path),
                                fit: BoxFit.cover,
                              ))
                      : (_existingCoverImageUrl != null &&
                                _existingCoverImageUrl!.isNotEmpty
                            ? Image.network(
                                _existingCoverImageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      color: AppColors.textMuted,
                                    ),
                                  );
                                },
                              )
                            : Center(
                                child: Text(
                                  'No image',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              )),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _pickImage,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: AppColors.available,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  child: Text(
                    'Choose image',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.available,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveProject,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                        0xFFC69C6D,
                      ), // Gold/Tan color from mockup
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: context.watch<InventoryProvider>().isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            'Save Project',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 2.0),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textPrimary),
      validator: validator,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.borderLight,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.borderLight,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.rejected, width: 1.5),
        ),
      ),
    );
  }
}
