import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _shakeEnabled = true;
  bool _hardwareEnabled = true;
  bool _voiceEnabled = false;
  bool _silentDefault = false;
  bool _autoAudio = true;
  bool _autoVideo = false;
  bool _anonymousMode = false;
  double _radius = 1.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('SETTINGS'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          children: [
            // ─── Trigger Configuration Section ─────────────────────────────
            _sectionHeader('Emergency Triggers'),
            _buildSwitchTile(
              title: 'Shake Trigger',
              subtitle: 'Trigger SOS by aggressively shaking phone',
              value: _shakeEnabled,
              icon: Icons.vibration,
              onChanged: (val) => setState(() => _shakeEnabled = val),
            ),
            _buildSwitchTile(
              title: 'Power Button Combos',
              subtitle: 'Press Power button 3-5 times rapidly to trigger',
              value: _hardwareEnabled,
              icon: Icons.power_settings_new,
              onChanged: (val) => setState(() => _hardwareEnabled = val),
            ),
            _buildSwitchTile(
              title: 'Voice Activation',
              subtitle: 'Detect secret words like "help me"',
              value: _voiceEnabled,
              icon: Icons.keyboard_voice_outlined,
              onChanged: (val) => setState(() => _voiceEnabled = val),
            ),
            const SizedBox(height: 24),

            // ─── Network Settings Section ──────────────────────────────────
            _sectionHeader('Pulse Network Radius'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Broadcast Distance',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${_radius.toStringAsFixed(1)} km',
                        style: const TextStyle(color: AppColors.electricCyan, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: _radius,
                    min: 0.5,
                    max: 3.0,
                    divisions: 5,
                    label: '${_radius.toStringAsFixed(1)} km',
                    activeColor: AppColors.electricCyan,
                    inactiveColor: AppColors.borderDark,
                    onChanged: (val) {
                      setState(() {
                        _radius = val;
                      });
                    },
                  ),
                  Text(
                    'SOS broadcasts will reach verified responders and nearby active network within this custom range.',
                    style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textTertiary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ─── Evidence capture Section ──────────────────────────────────
            _sectionHeader('Evidence & Buffer Capture'),
            _buildSwitchTile(
              title: 'Auto Record Audio',
              subtitle: 'Instantly launch secure microphone buffer',
              value: _autoAudio,
              icon: Icons.mic_none_outlined,
              onChanged: (val) => setState(() => _autoAudio = val),
            ),
            _buildSwitchTile(
              title: 'Auto Record Video',
              subtitle: 'Initiate camera streams on high-priority alerts',
              value: _autoVideo,
              icon: Icons.videocam_outlined,
              onChanged: (val) => setState(() => _autoVideo = val),
            ),
            const SizedBox(height: 24),

            // ─── Privacy Section ───────────────────────────────────────────
            _sectionHeader('Privacy Controls'),
            _buildSwitchTile(
              title: 'Silent Mode Default',
              subtitle: 'Start all active SOS broadcasts in silent mode',
              value: _silentDefault,
              icon: Icons.volume_mute_outlined,
              onChanged: (val) => setState(() => _silentDefault = val),
            ),
            _buildSwitchTile(
              title: 'Anonymous Mode',
              subtitle: 'Mask exact name and profile from general responders',
              value: _anonymousMode,
              icon: Icons.privacy_tip_outlined,
              onChanged: (val) => setState(() => _anonymousMode = val),
            ),
            const SizedBox(height: 40),

            // Version number
            const Center(
              child: Text(
                'PulseSOS v1.0.0 — Stable Build',
                style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String label) {
    return Padding(
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
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.electricCyan.withOpacity(0.1),
          ),
          child: Icon(icon, color: AppColors.electricCyan, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
