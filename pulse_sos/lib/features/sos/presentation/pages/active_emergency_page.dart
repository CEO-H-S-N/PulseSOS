import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart';
import '../../domain/repositories/incident_repository.dart';
import '../bloc/sos_bloc.dart';

class ActiveEmergencyPage extends StatefulWidget {
  const ActiveEmergencyPage({super.key});

  @override
  State<ActiveEmergencyPage> createState() => _ActiveEmergencyPageState();
}

class _ActiveEmergencyPageState extends State<ActiveEmergencyPage> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  GoogleMapController? _mapController;

  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(AppConstants.defaultLatitude, AppConstants.defaultLongitude),
    zoom: AppConstants.defaultZoom + 1,
  );

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sosState = context.watch<SOSBloc>().state;

    // Redirect to home if state is idle
    if (sosState is SOSIdle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (sosState is SOSCountingDown) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'ALERT INITIATED',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: AppColors.emergencyRed,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'PulseSOS is preparing to notify nearby community network.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              // Glowing Countdown Circle
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    height: 180 + (20 * _pulseController.value),
                    width: 180 + (20 * _pulseController.value),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.emergencyRed.withOpacity(0.08),
                      border: Border.all(
                        color: AppColors.emergencyRed.withOpacity(0.5 + (0.5 * _pulseController.value)),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.emergencyRed.withOpacity(0.2 * _pulseController.value),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '${sosState.secondsRemaining}',
                        style: theme.textTheme.displayLarge?.copyWith(
                          color: Colors.white,
                          fontSize: 70,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 60),
              Text(
                'Incident: ${sosState.type.label.toUpperCase()}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 60),
              ElevatedButton(
                onPressed: () {
                  context.read<SOSBloc>().add(SOSCancelled());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surfaceDark,
                  side: BorderSide(color: AppColors.borderDark),
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                ),
                child: const Text(
                  'CANCEL ALERT',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (sosState is SOSActive) {
      final incident = sosState.incident;
      return Scaffold(
        body: Stack(
          children: [
            // Active tracking Map
            GoogleMap(
              initialCameraPosition: _initialCameraPosition,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapType: MapType.dark,
              onMapCreated: (controller) {
                _mapController = controller;
              },
            ),

            // Top Status Bar Banner
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.emergencyRed.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.emergency_share, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'SOS BROADCAST ACTIVE',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            Text(
                              'Locating nearby community responders...',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // AI Insight Panel (Injected feature)
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 100.0, left: 16, right: 16),
                  child: FutureBuilder<dynamic>(
                    // Using getAIInsights to fetch orchestrator data. Fails gracefully.
                    future: sl<IncidentRepository>().getAIInsights(incident.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox.shrink();
                      }
                      if (snapshot.hasError || !snapshot.hasData || snapshot.data?.isLeft == true) {
                        return const SizedBox.shrink(); // Fallback to standard UI
                      }
                      
                      final aiData = snapshot.data!.right as Map<String, dynamic>;
                      final summary = aiData['summary'] ?? 'AI monitoring active...';
                      final safetyRec = aiData['recommendation'] ?? '';

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceDark.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.electricCyan.withOpacity(0.5)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.psychology, color: AppColors.electricCyan, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  'AI ORCHESTRATOR INSIGHTS',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: AppColors.electricCyan,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              summary,
                              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white),
                            ),
                            if (safetyRec.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                safetyRec,
                                style: theme.textTheme.labelSmall?.copyWith(color: AppColors.neonGreen),
                              ),
                            ]
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Bottom incident stats & Action Panel
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border.all(color: AppColors.borderDark),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Quick Status Indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 8,
                              width: 8,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.emergencyRed,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'EVIDENCE: BUFFERING AUDIO',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: AppColors.emergencyRed,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'RESPONDERS: ${incident.responderCount}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: AppColors.electricCyan,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // Responders list stub
                    if (incident.responders.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          'Waiting for first responder to join...',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textTertiary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    else
                      SizedBox(
                        height: 60,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: incident.responders.length,
                          itemBuilder: (context, index) {
                            final responder = incident.responders[index];
                            return Container(
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.cardDark,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.borderDark),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor: AppColors.electricCyan.withOpacity(0.1),
                                    child: const Icon(Icons.person, size: 14, color: AppColors.electricCyan),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        responder.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                                      ),
                                      Text(
                                        responder.role.toUpperCase(),
                                        style: const TextStyle(color: AppColors.neonGreen, fontSize: 9),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 20),

                    // Giant Resolve Emergency Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<SOSBloc>().add(SOSResolved());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.neonGreen,
                          foregroundColor: AppColors.deepBlack,
                        ),
                        child: const Text(
                          'I AM SAFE — RESOLVE',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (sosState is SOSResolvedState) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.neonGreen.withOpacity(0.1),
                    border: Border.all(color: AppColors.neonGreen, width: 2),
                  ),
                  child: const Icon(
                    Icons.gpp_good_outlined,
                    color: AppColors.neonGreen,
                    size: 70,
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'EMERGENCY RESOLVED',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'The community has been notified of your safety. Glad you are safe.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60),
                ElevatedButton(
                  onPressed: () {
                    context.read<SOSBloc>().add(SOSCancelled());
                  },
                  child: const Text('Back to Home'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
