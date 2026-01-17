import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/auth_screen.dart';
import '../../features/auth/presentation/pages/verify_email_screen.dart';
import '../../features/auth/presentation/pages/forgot_password_screen.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/report/presentation/pages/reports_list_page.dart';
import '../../features/report/presentation/pages/report_details_page.dart';
import '../../features/report/presentation/pages/new_report_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/settings_page.dart';
import '../../features/profile/presentation/pages/privacy_controls_page.dart';
import '../../features/profile/presentation/pages/notification_preferences_page.dart';
import '../../features/profile/presentation/pages/saved_reports_page.dart';
import '../../features/profile/presentation/pages/security_page.dart';
import '../../features/profile/presentation/pages/help_support_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/verify/presentation/pages/verify_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_screen.dart';
import '../widgets/main_scaffold.dart';
import '../widgets/splash_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home', // Changed from '/splash' to skip auth
    debugLogDiagnostics: true,
    redirect: (context, state) {
      // DISABLED FOR DEVELOPMENT - Skip all authentication checks
      // TODO: Re-enable authentication before production deployment
      return null;

      /* ORIGINAL AUTH LOGIC - COMMENTED OUT FOR DEVELOPMENT
      final authState = context.read<AuthBloc>().state;
      final isLoggedIn = authState.status == AuthStatus.authenticated;
      final isLoggingIn = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/forgot-password';
      final isSplash = state.matchedLocation == '/splash';
      final isPublicRoute = state.matchedLocation == '/track-report' ||
          state.matchedLocation.startsWith('/track/');

      // Allow public routes
      if (isPublicRoute) return null;

      // If checking auth status, show splash
      if (authState.status == AuthStatus.loading && isSplash) return null;

      // If not logged in and not on login/register, redirect to login
      if (!isLoggedIn && !isLoggingIn && !isSplash) {
        return '/login';
      }

      // If logged in and on login/register, redirect to home
      if (isLoggedIn && isLoggingIn) {
        return '/home';
      }

      return null;
      */
    },
    routes: [
      // Splash Screen
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Onboarding Screen
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Auth Routes
      GoRoute(path: '/login', builder: (context, state) => const AuthScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return VerifyEmailScreen(
            userId: extra?['userId'] as String?,
            email: extra?['email'] as String?,
          );
        },
      ),
      GoRoute(
        path: '/2fa',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return VerifyEmailScreen(
            userId: extra?['userId'] as String?,
            email: extra?['email'] as String?,
          );
        },
      ),

      // Main App Shell with Bottom Navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HomePage()),
          ),
          GoRoute(
            path: '/reports',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ReportsListPage()),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) => const NewReportPage(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return ReportDetailsPage(reportId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/verify',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: VerifyPage()),
          ),
          GoRoute(
            path: '/notifications',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: NotificationsPage()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProfilePage()),
            routes: [
              GoRoute(
                path: 'settings',
                builder: (context, state) => const SettingsPage(),
              ),
              GoRoute(
                path: 'privacy',
                builder: (context, state) => const PrivacyControlsPage(),
              ),
              GoRoute(
                path: 'notifications',
                builder: (context, state) =>
                    const NotificationPreferencesPage(),
              ),
              GoRoute(
                path: 'saved-reports',
                builder: (context, state) => const SavedReportsPage(),
              ),
              GoRoute(
                path: 'security',
                builder: (context, state) => const SecurityPage(),
              ),
              GoRoute(
                path: 'help',
                builder: (context, state) => const HelpSupportPage(),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(state.matchedLocation),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
