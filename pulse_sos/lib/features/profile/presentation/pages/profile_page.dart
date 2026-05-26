import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.watch<AuthBloc>().state;

    UserEntity? user;
    if (authState is AuthAuthenticated) {
      user = authState.user;
    }

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('RESPONDER PROFILE'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ─── Avatar & Name Block ───────────────────────────────────────
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
                    if (user.isVerifiedResponder)
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.electricCyan,
                          ),
                          child: const Icon(
                            Icons.verified,
                            size: 16,
                            color: AppColors.deepBlack,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user.displayName,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.phone,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 24),

              // ─── Gamified Trust Levels Panel ──────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderDark),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Community Trust Score',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${user.trustLevel.toInt()}%',
                          style: const TextStyle(color: AppColors.electricCyan, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: user.trustLevel / 100.0,
                        minHeight: 8,
                        backgroundColor: AppColors.borderDark,
                        valueColor: const AlwaysStoppedAnimation(AppColors.electricCyan),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatBox('Help Score', '${user.helpfulnessScore.toInt()}'),
                        Container(height: 30, width: 1, color: AppColors.borderDark),
                        _buildStatBox('Responses', '${user.totalResponses}'),
                        Container(height: 30, width: 1, color: AppColors.borderDark),
                        _buildStatBox('Role', user.responderRole.toUpperCase()),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ─── Profile details Section ──────────────────────────────────
              _sectionHeader('Medical Credentials'),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderDark),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Blood Group', user.bloodGroup ?? 'Not configured'),
                    const SizedBox(height: 12),
                    _buildInfoRow('Gender', user.gender ?? 'Not configured'),
                    const SizedBox(height: 12),
                    const Text(
                      'Chronic Conditions / Allergies:',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    user.medicalConditions.isEmpty
                        ? const Text('None reported', style: TextStyle(color: Colors.white))
                        : Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: user.medicalConditions.map((item) {
                              return Chip(
                                label: Text(item, style: const TextStyle(fontSize: 12)),
                              );
                            }).toList(),
                          ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ─── Quick Actions Section ─────────────────────────────────────
              _sectionHeader('Account Actions'),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.push('/profile-setup'),
                  child: const Text('EDIT PROFILE DETAILS'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(AuthSignOutRequested());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emergencyRed,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('SIGN OUT'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4.0, bottom: 12.0),
        child: Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.bold,
            fontSize: 11,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
