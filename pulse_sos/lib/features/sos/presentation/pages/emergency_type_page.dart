import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/incident_entity.dart';
import '../bloc/sos_bloc.dart';

class EmergencyTypePage extends StatefulWidget {
  const EmergencyTypePage({super.key});

  @override
  State<EmergencyTypePage> createState() => _EmergencyTypePageState();
}

class _EmergencyTypePageState extends State<EmergencyTypePage> {
  bool _isSilent = false;

  final List<EmergencyTypeItem> _types = [
    EmergencyTypeItem(
      type: EmergencyType.robbery,
      label: AppStrings.robbery,
      icon: Icons.local_police_outlined,
      color: AppColors.robbery,
    ),
    EmergencyTypeItem(
      type: EmergencyType.medical,
      label: AppStrings.medicalEmergency,
      icon: Icons.medical_services_outlined,
      color: AppColors.medical,
    ),
    EmergencyTypeItem(
      type: EmergencyType.fire,
      label: AppStrings.fireEmergency,
      icon: Icons.local_fire_department_outlined,
      color: AppColors.fire,
    ),
    EmergencyTypeItem(
      type: EmergencyType.harassment,
      label: AppStrings.harassmentEmergency,
      icon: Icons.gpp_maybe_outlined,
      color: AppColors.harassment,
    ),
    EmergencyTypeItem(
      type: EmergencyType.accident,
      label: AppStrings.accidentEmergency,
      icon: Icons.car_crash_outlined,
      color: AppColors.accident,
    ),
    EmergencyTypeItem(
      type: EmergencyType.kidnapping,
      label: AppStrings.kidnappingEmergency,
      icon: Icons.warning_amber_outlined,
      color: AppColors.kidnapping,
    ),
    EmergencyTypeItem(
      type: EmergencyType.other,
      label: AppStrings.otherEmergency,
      icon: Icons.more_horiz_outlined,
      color: AppColors.other,
    ),
  ];

  void _triggerEmergency(BuildContext context, EmergencyType type) {
    context.read<SOSBloc>().add(
          SOSInitiated(type: type, isSilent: _isSilent),
        );
    context.go('/active-emergency');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.selectEmergencyType.toUpperCase(),
          style: const TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Silent mode quick card toggle
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderDark),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isSilent ? Icons.volume_off : Icons.volume_up,
                          color: _isSilent ? AppColors.warningAmber : AppColors.electricCyan,
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Silent Alert Mode',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _isSilent ? 'Disables local audio alarms' : 'Siren sounds on activation',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Switch(
                      value: _isSilent,
                      onChanged: (val) {
                        setState(() {
                          _isSilent = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Category title
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Select category to launch SOS'.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Grid of Options
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: _types.length,
                  itemBuilder: (context, index) {
                    final item = _types[index];
                    return GestureDetector(
                      onTap: () => _triggerEmergency(context, item.type),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.cardDark,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderDark),
                          boxShadow: [
                            BoxShadow(
                              color: item.color.withOpacity(0.05),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: item.color.withOpacity(0.1),
                              ),
                              child: Icon(
                                item.icon,
                                color: item.color,
                                size: 30,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              item.label,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmergencyTypeItem {
  final EmergencyType type;
  final String label;
  final IconData icon;
  final Color color;

  EmergencyTypeItem({
    required this.type,
    required this.label,
    required this.icon,
    required this.color,
  });
}
