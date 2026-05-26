import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/user_entity.dart';
import '../bloc/auth_bloc.dart';

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _medicalController = TextEditingController();
  final TextEditingController _vehicleTypeController = TextEditingController();
  final TextEditingController _vehicleNumController = TextEditingController();

  String? _selectedBloodGroup;
  String? _selectedGender;

  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final List<String> _genders = ['Male', 'Female', 'Other', 'Prefer not to say'];

  @override
  void dispose() {
    _nameController.dispose();
    _medicalController.dispose();
    _vehicleTypeController.dispose();
    _vehicleNumController.dispose();
    super.dispose();
  }

  void _saveProfile(UserEntity currentUser) {
    if (_formKey.currentState?.validate() ?? false) {
      final medicalConditions = _medicalController.text.trim().isNotEmpty
          ? _medicalController.text.split(',').map((e) => e.trim()).toList()
          : <String>[];

      final vehicleDetails = _vehicleTypeController.text.trim().isNotEmpty &&
              _vehicleNumController.text.trim().isNotEmpty
          ? VehicleDetails(
              type: _vehicleTypeController.text.trim(),
              number: _vehicleNumController.text.trim(),
            )
          : null;

      final updatedUser = currentUser.copyWith(
        displayName: _nameController.text.trim(),
        bloodGroup: _selectedBloodGroup,
        gender: _selectedGender,
        medicalConditions: medicalConditions,
        vehicleDetails: vehicleDetails,
      );

      context.read<AuthBloc>().add(AuthProfileUpdateRequested(updatedUser));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.watch<AuthBloc>().state;

    UserEntity? currentUser;
    if (authState is AuthNeedsProfile) {
      currentUser = authState.user;
    } else if (authState is AuthAuthenticated) {
      currentUser = authState.user;
    }

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.setupProfile),
        centerTitle: true,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.emergencyRed,
              ),
            );
          }
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 54,
                          backgroundColor: AppColors.electricCyan.withOpacity(0.1),
                          child: const Icon(
                            Icons.person,
                            size: 60,
                            color: AppColors.electricCyan,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            height: 36,
                            width: 36,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.electricCyan,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 18,
                              color: AppColors.deepBlack,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: AppStrings.fullName,
                      prefixIcon: const Icon(Icons.person_outline, color: AppColors.electricCyan),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Full name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedBloodGroup,
                          dropdownColor: AppColors.surfaceDark,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: AppStrings.bloodGroup,
                            prefixIcon: const Icon(Icons.bloodtype_outlined, color: AppColors.electricCyan),
                          ),
                          items: _bloodGroups.map((bg) {
                            return DropdownMenuItem(
                              value: bg,
                              child: Text(bg),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedBloodGroup = val;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedGender,
                          dropdownColor: AppColors.surfaceDark,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: AppStrings.gender,
                            prefixIcon: const Icon(Icons.wc_outlined, color: AppColors.electricCyan),
                          ),
                          items: _genders.map((g) {
                            return DropdownMenuItem(
                              value: g,
                              child: Text(g),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedGender = val;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _medicalController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: AppStrings.medicalConditions,
                      hintText: 'e.g. Asthma, Diabetes, None',
                      prefixIcon: const Icon(Icons.medical_services_outlined, color: AppColors.electricCyan),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    '${AppStrings.vehicleDetails} (Optional)',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _vehicleTypeController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Vehicle Type',
                            hintText: 'e.g. Car, Bike',
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _vehicleNumController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'License Plate',
                            hintText: 'e.g. ABC-123',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;
                      return SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : () => _saveProfile(currentUser!),
                          child: isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                      AppColors.deepBlack,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Complete Setup',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
