import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../sos/domain/entities/incident_entity.dart';

class IncidentHistoryPage extends StatelessWidget {
  const IncidentHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Static sample data representing complete incident logs
    final List<IncidentLogItem> logs = [
      IncidentLogItem(
        type: EmergencyType.robbery,
        victimName: 'Sarah Connor',
        status: IncidentStatus.resolved,
        distanceAway: '300m away',
        time: 'Today, 2:14 PM',
        actionTaken: 'You Responded (Arrived)',
      ),
      IncidentLogItem(
        type: EmergencyType.medical,
        victimName: 'John Doe',
        status: IncidentStatus.resolved,
        distanceAway: '1.2 km away',
        time: 'Yesterday, 8:45 PM',
        actionTaken: 'Alert Broadcast Only',
      ),
      IncidentLogItem(
        type: EmergencyType.harassment,
        victimName: 'Mary Jane',
        status: IncidentStatus.falseAlarm,
        distanceAway: '500m away',
        time: 'May 18, 11:20 AM',
        actionTaken: 'Cancelled',
      ),
      IncidentLogItem(
        type: EmergencyType.accident,
        victimName: 'Robert Vance',
        status: IncidentStatus.resolved,
        distanceAway: '2.5 km away',
        time: 'May 15, 6:30 PM',
        actionTaken: 'You Responded (Helping)',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('INCIDENT ARCHIVE'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderDark),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.history_toggle_off, color: AppColors.electricCyan, size: 28),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Incident Logs Archive',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Historical details of SOS events triggered within your community network.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'RECENT LOGS',
                style: theme.textTheme.labelSmall?.copyWith(
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final item = logs[index];
                    final color = AppColors.incidentTypeColor(item.type.name);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardDark,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderDark),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color.withOpacity(0.1),
                            ),
                            child: Icon(
                              _getIconForType(item.type),
                              color: color,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      item.type.label.toUpperCase(),
                                      style: TextStyle(
                                        color: color,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.statusColor(item.status.name).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        item.status.label.toUpperCase(),
                                        style: TextStyle(
                                          color: AppColors.statusColor(item.status.name),
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Victim: ${item.victimName}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      item.distanceAway,
                                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(height: 8, width: 1, color: AppColors.borderDark),
                                    const SizedBox(width: 8),
                                    Text(
                                      item.time,
                                      style: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Icon(Icons.check_circle_outline, size: 14, color: AppColors.neonGreen),
                                    const SizedBox(width: 6),
                                    Text(
                                      item.actionTaken,
                                      style: const TextStyle(
                                        color: AppColors.neonGreen,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
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

  IconData _getIconForType(EmergencyType type) {
    switch (type) {
      case EmergencyType.robbery: return Icons.local_police_outlined;
      case EmergencyType.medical: return Icons.medical_services_outlined;
      case EmergencyType.fire: return Icons.local_fire_department_outlined;
      case EmergencyType.harassment: return Icons.gpp_maybe_outlined;
      case EmergencyType.accident: return Icons.car_crash_outlined;
      case EmergencyType.kidnapping: return Icons.warning_amber_outlined;
      default: return Icons.more_horiz_outlined;
    }
  }
}

class IncidentLogItem {
  final EmergencyType type;
  final String victimName;
  final IncidentStatus status;
  final String distanceAway;
  final String time;
  final String actionTaken;

  IncidentLogItem({
    required this.type,
    required this.victimName,
    required this.status,
    required this.distanceAway,
    required this.time,
    required this.actionTaken,
  });
}
