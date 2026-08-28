import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/auth/auth_controller.dart';
import 'core/di.dart';
import 'features/auth/login_page.dart';
import 'features/dashboard/dashboard_page.dart';
import 'features/users/users_page.dart';
import 'features/games/games_list_page.dart';
import 'features/games/game_detail_page.dart';
import 'features/tournaments/tournaments_page.dart';
import 'features/rewards/rewards_page.dart';
import 'features/wallet/wallet_page.dart';
import 'features/payments/payments_page.dart';
import 'features/content/content_page.dart';
import 'features/notifications/notifications_page.dart';
import 'features/reports/reports_page.dart';
import 'shared/stub_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/dashboard',
  refreshListenable: authController,
  redirect: (context, state) {
    final status = authController.status;
    final loggingIn = state.matchedLocation == '/login';

    // Session not yet resolved — don't bounce anywhere.
    if (status == AuthStatus.unknown) return null;

    if (status == AuthStatus.unauthenticated) {
      return loggingIn ? null : '/login';
    }
    // Authenticated: keep them out of the login screen.
    if (loggingIn) return '/dashboard';
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      pageBuilder: (_, state) => const NoTransitionPage(child: LoginPage()),
    ),
    GoRoute(
      path: '/dashboard',
      pageBuilder: (_, state) => const NoTransitionPage(child: DashboardPage()),
    ),
    GoRoute(
      path: '/users',
      pageBuilder: (_, state) => const NoTransitionPage(child: UsersPage()),
    ),
    GoRoute(
      path: '/games',
      pageBuilder: (_, state) => const NoTransitionPage(child: GamesListPage()),
    ),
    GoRoute(
      path: '/games/:key',
      pageBuilder: (_, state) => NoTransitionPage(
        child: GameDetailPage(
          gameKey: state.pathParameters['key'] ?? 'picture_puzzle',
        ),
      ),
    ),
    GoRoute(
      path: '/tournaments',
      pageBuilder: (_, state) => const NoTransitionPage(child: TournamentsPage()),
    ),
    GoRoute(
      path: '/rewards',
      pageBuilder: (_, state) => const NoTransitionPage(child: RewardsPage()),
    ),
    GoRoute(
      path: '/wallet',
      pageBuilder: (_, state) => const NoTransitionPage(child: WalletPage()),
    ),
    GoRoute(
      path: '/payments',
      pageBuilder: (_, state) => const NoTransitionPage(child: PaymentsPage()),
    ),
    GoRoute(
      path: '/content',
      pageBuilder: (_, state) => const NoTransitionPage(child: ContentPage()),
    ),
    GoRoute(
      path: '/notifications',
      pageBuilder: (_, state) => const NoTransitionPage(child: NotificationsPage()),
    ),
    GoRoute(
      path: '/reports',
      pageBuilder: (_, state) => const NoTransitionPage(child: ReportsPage()),
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (_, state) => const NoTransitionPage(
        child: StubPage(
            title: 'Settings', route: '/settings', icon: Icons.settings_outlined),
      ),
    ),
  ],
);
