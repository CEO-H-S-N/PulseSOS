import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/sos_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  GoogleMapController? _mapController;

  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(AppConstants.defaultLatitude, AppConstants.defaultLongitude),
    zoom: AppConstants.defaultZoom,
  );

  bool _isSilentMode = false;
  double _currentRadius = AppConstants.nearbyRadiusMedium;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _triggerQuickSOS() {
    // Quick trigger navigation to Type Selection
    context.push('/emergency-type');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.watch<AuthBloc>().state;

    String userName = 'User';
    bool isVerified = false;

    if (authState is AuthAuthenticated) {
      userName = authState.user.displayName;
      isVerified = authState.user.isVerifiedResponder;
    }

    return Scaffold(
      body: Stack(
        children: [
          // ─── Google Maps Layer ─────────────────────────────────────
          GoogleMap(
            initialCameraPosition: _initialCameraPosition,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapType: MapType.dark,
            onMapCreated: (controller) {
              _mapController = controller;
              // Apply custom dark style here in standard implementation
            },
          ),

          // ─── Header overlay ────────────────────────────────────────
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Avatar & Info Card
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: AppColors.borderDark),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.electricCyan.withOpacity(0.1),
                            child: const Icon(
                              Icons.person,
                              size: 18,
                              color: AppColors.electricCyan,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                userName,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    height: 6,
                                    width: 6,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.neonGreen,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'SHIELD ONLINE',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: AppColors.neonGreen,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (isVerified) ...[
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.verified,
                              size: 16,
                              color: AppColors.electricCyan,
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Quick Settings Buttons
                    Row(
                      children: [
                        // Siren mode indicator/toggle
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _isSilentMode = !_isSilentMode;
                            });
                          },
                          icon: Icon(
                            _isSilentMode ? Icons.volume_off : Icons.volume_up,
                            color: _isSilentMode ? AppColors.warningAmber : AppColors.electricCyan,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.surfaceDark.withOpacity(0.85),
                            side: BorderSide(color: AppColors.borderDark),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Quick Radius indicator
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if (_currentRadius == AppConstants.nearbyRadiusSmall) {
                                _currentRadius = AppConstants.nearbyRadiusMedium;
                              } else if (_currentRadius == AppConstants.nearbyRadiusMedium) {
                                _currentRadius = AppConstants.nearbyRadiusLarge;
                              } else {
                                _currentRadius = AppConstants.nearbyRadiusSmall;
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceDark.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.borderDark),
                            ),
                            child: Text(
                              '${_currentRadius.toInt()} km',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: AppColors.electricCyan,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ─── Center / Background Glowing radar ───────────────────────
          Align(
            alignment: Alignment.center,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: List.generate(3, (index) {
                    final double progress = (_pulseController.value + index / 3) % 1.0;
                    return Container(
                      height: 350 * progress,
                      width: 350 * progress,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.electricCyan.withOpacity(1.0 - progress),
                          width: 1,
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),

          // ─── Bottom SOS Action Area ─────────────────────────────────
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Quick Info warning banner
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderDark),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.gpp_maybe,
                          color: AppColors.warningAmber,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Tap button below to select emergency type and alert neighbors.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Giant Glowing SOS Button
                  GestureDetector(
                    onTap: _triggerQuickSOS,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // SOS Ripple Effect
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Container(
                              height: 160 + (30 * _pulseController.value),
                              width: 160 + (30 * _pulseController.value),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.emergencyRed.withOpacity(0.15 * (1.0 - _pulseController.value)),
                              ),
                            );
                          },
                        ),
                        Container(
                          height: 140,
                          width: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.sosPulseGradient,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.emergencyRed.withOpacity(0.4),
                                blurRadius: 25,
                                spreadRadius: 5,
                              )
                            ],
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.warning_rounded,
                                  color: Colors.white,
                                  size: 32,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'SOS',
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
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
        ],
      ),
    );
  }
}
