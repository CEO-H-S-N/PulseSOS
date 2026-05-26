import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/otp_page.dart';
import '../features/auth/presentation/pages/profile_setup_page.dart';
import '../features/onboarding/presentation/pages/onboarding_page.dart';
import '../features/sos/presentation/pages/home_page.dart';
import '../features/sos/presentation/pages/active_emergency_page.dart';
import '../features/incidents/presentation/pages/incident_history_page.dart';
import '../features/contacts/presentation/pages/contacts_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../features/sos/presentation/pages/emergency_type_page.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter router(AuthState authState) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/',
      redirect: (context, state) {
        final isOnboarding = state.matchedLocation == '/onboarding';
        final isAuth = state.matchedLocation.startsWith('/auth');
        final isProfileSetup = state.matchedLocation == '/profile-setup';

        if (authState is AuthInitial || authState is AuthLoading) {
          return null; // Show loading
        }

        if (authState is AuthUnauthenticated) {
          if (isAuth || isOnboarding) return null;
          return '/onboarding';
        }

        if (authState is AuthOtpSent) {
          return '/auth/otp';
        }

        if (authState is AuthNeedsProfile) {
          if (isProfileSetup) return null;
          return '/profile-setup';
        }

        if (authState is AuthAuthenticated) {
          if (isAuth || isOnboarding || isProfileSetup) return '/';
          return null;
        }

        return null;
      },
      routes: [
        // ─── Onboarding ─────────────────────
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingPage(),
        ),

        // ─── Auth ────────────────────────────
        GoRoute(
          path: '/auth/login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/auth/otp',
          builder: (context, state) => const OtpPage(),
        ),

        // ─── Profile Setup ───────────────────
        GoRoute(
          path: '/profile-setup',
          builder: (context, state) => const ProfileSetupPage(),
        ),

        // ─── Main App (Shell) ────────────────
        ShellRoute(
          builder: (context, state, child) => MainShell(child: child),
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const HomePage(),
            ),
            GoRoute(
              path: '/incidents',
              builder: (context, state) => const IncidentHistoryPage(),
            ),
            GoRoute(
              path: '/contacts',
              builder: (context, state) => const ContactsPage(),
            ),
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfilePage(),
            ),
          ],
        ),

        // ─── Full-screen Routes ──────────────
        GoRoute(
          path: '/emergency-type',
          builder: (context, state) => const EmergencyTypePage(),
        ),
        GoRoute(
          path: '/active-emergency',
          builder: (context, state) => const ActiveEmergencyPage(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsPage(),
        ),
      ],
    );
  }
}

/// Main shell with bottom navigation
class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location == '/') return 0;
    if (location == '/incidents') return 1;
    if (location == '/contacts') return 2;
    if (location == '/profile') return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex(context),
          onDestinationSelected: (index) {
            switch (index) {
              case 0: context.go('/');
              case 1: context.go('/incidents');
              case 2: context.go('/contacts');
              case 3: context.go('/profile');
            }
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.shield_outlined),
              selectedIcon: Icon(Icons.shield),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_outlined),
              selectedIcon: Icon(Icons.history),
              label: 'History',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outline),
              selectedIcon: Icon(Icons.people),
              label: 'Contacts',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
