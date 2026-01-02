// lib/screens/profile/edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/helpers.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_textfield.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.user;

    if (currentUser == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Create updated user
    final updatedUser = currentUser.copyWith(
      name: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      updatedAt: DateTime.now(),
    );

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    final success = await authProvider.updateUser(updatedUser);

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (success) {
      Helpers.showSnackBar(context, AppStrings.profileUpdated);
      Navigator.pop(context);
    } else {
      Helpers.showSnackBar(
        context,
        authProvider.errorMessage ?? 'Failed to update profile',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(AppStrings.editProfile),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Picture
              Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primaryLight,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        user != null ? user.name[0].toUpperCase() : 'G',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.white,
                          width: 3,
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: AppColors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Email (Read Only)
              CustomTextField(
                controller: TextEditingController(text: user?.email ?? ''),
                label: AppStrings.email,
                enabled: false,
                prefixIcon: Icons.email_outlined,
              ),

              const SizedBox(height: 16),

              // Name Field
              CustomTextField(
                controller: _nameController,
                label: AppStrings.fullName,
                hintText: 'Enter your name',
                prefixIcon: Icons.person_outline,
                validator: Validators.validateName,
              ),

              const SizedBox(height: 16),

              // Phone Field
              CustomTextField(
                controller: _phoneController,
                label: AppStrings.phoneNumber,
                hintText: 'Enter your phone number',
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  return Validators.validatePhone(value);
                },
              ),

              const SizedBox(height: 32),

              // Save Button
              CustomButton(
                text: AppStrings.save,
                isLoading: _isLoading,
                onPressed: _handleSave,
              ),

              const SizedBox(height: 16),

              // Additional Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.info,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your email address cannot be changed',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.info,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}