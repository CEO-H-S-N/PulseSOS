import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final List<TrustedContact> _contacts = [
    TrustedContact(
      name: 'Sarah Connor',
      relationship: 'Mother',
      phone: '+1 (555) 123-4567',
      email: 'sarah@skynet.com',
      notifyViaSms: true,
      notifyViaWhatsapp: true,
    ),
    TrustedContact(
      name: 'John Connor',
      relationship: 'Brother',
      phone: '+1 (555) 987-6543',
      email: 'john@skynet.com',
      notifyViaSms: true,
      notifyViaWhatsapp: false,
    ),
  ];

  void _addContact() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ADD TRUSTED CONTACT',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 20),
              const TextFormField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline, color: AppColors.electricCyan),
                ),
              ),
              const SizedBox(height: 16),
              const TextFormField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Relationship',
                  prefixIcon: Icon(Icons.family_restroom_outlined, color: AppColors.electricCyan),
                ),
              ),
              const SizedBox(height: 16),
              const TextFormField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone_outlined, color: AppColors.electricCyan),
                ),
              ),
              const SizedBox(height: 16),
              const TextFormField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.mail_outline, color: AppColors.electricCyan),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Contact added successfully'),
                        backgroundColor: AppColors.neonGreen,
                      ),
                    );
                  },
                  child: const Text('SAVE CONTACT'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('TRUSTED CIRCLE'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addContact,
        backgroundColor: AppColors.electricCyan,
        child: const Icon(Icons.person_add, color: AppColors.deepBlack),
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
                    const Icon(Icons.shield_outlined, color: AppColors.electricCyan, size: 28),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Trusted Circle Protection',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'These contacts will receive automatic SMS, Email and WhatsApp tracking links when you trigger SOS.',
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
                'YOUR CONTACTS',
                style: theme.textTheme.labelSmall?.copyWith(
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _contacts.isEmpty
                    ? Center(
                        child: Text(
                          'No trusted contacts added yet.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _contacts.length,
                        itemBuilder: (context, index) {
                          final contact = _contacts[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.cardDark,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.borderDark),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: AppColors.electricCyan.withOpacity(0.1),
                                  child: Text(
                                    contact.name.substring(0, 1),
                                    style: const TextStyle(
                                      color: AppColors.electricCyan,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            contact.name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.electricCyan.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              contact.relationship.toUpperCase(),
                                              style: const TextStyle(
                                                color: AppColors.electricCyan,
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        contact.phone,
                                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          _ChannelIcon(icon: Icons.sms, enabled: contact.notifyViaSms, label: 'SMS'),
                                          const SizedBox(width: 12),
                                          _ChannelIcon(icon: Icons.chat, enabled: contact.notifyViaWhatsapp, label: 'WA'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: AppColors.emergencyRed),
                                  onPressed: () {
                                    setState(() {
                                      _contacts.removeAt(index);
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Contact removed'),
                                      ),
                                    );
                                  },
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
}

class _ChannelIcon extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final String label;

  const _ChannelIcon({
    required this.icon,
    required this.enabled,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: enabled ? AppColors.neonGreen : AppColors.textTertiary,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: enabled ? AppColors.neonGreen : AppColors.textTertiary,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class TrustedContact {
  final String name;
  final String relationship;
  final String phone;
  final String email;
  final bool notifyViaSms;
  final bool notifyViaWhatsapp;

  TrustedContact({
    required this.name,
    required this.relationship,
    required this.phone,
    required this.email,
    required this.notifyViaSms,
    required this.notifyViaWhatsapp,
  });
}
