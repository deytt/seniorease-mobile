import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/app/shell_scaffold.dart';
import 'package:mobile/features/accessibility/presentation/screens/accessibility_screen.dart';
import 'package:mobile/features/accessibility/presentation/screens/notification_preferences_screen.dart';
import 'package:mobile/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/features/auth/presentation/providers/biometric_provider.dart';
import 'package:mobile/features/auth/presentation/screens/biometric_lock_screen.dart';
import 'package:mobile/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:mobile/features/auth/presentation/screens/register_screen.dart';
import 'package:mobile/features/guides/presentation/screens/guides_screen.dart';
import 'package:mobile/features/history/presentation/screens/history_screen.dart';
import 'package:mobile/features/home/presentation/screens/home_screen.dart';
import 'package:mobile/features/profile/presentation/screens/about_screen.dart';
import 'package:mobile/features/profile/presentation/screens/profile_screen.dart';
import 'package:mobile/features/profile/presentation/screens/security_screen.dart';
import 'package:mobile/features/profile/presentation/screens/settings_screen.dart';
import 'package:mobile/features/reminders/domain/entities/reminder.dart';
import 'package:mobile/features/reminders/presentation/screens/create_reminder_screen.dart';
import 'package:mobile/features/reminders/presentation/screens/reminders_screen.dart';
import 'package:mobile/features/tasks/presentation/screens/create_task_screen.dart';
import 'package:mobile/features/tasks/presentation/screens/guided_task_screen.dart';
import 'package:mobile/features/tasks/presentation/screens/task_details_screen.dart';
import 'package:mobile/features/tasks/presentation/screens/task_list_screen.dart';

abstract final class AppRoutes {
  static const home = '/';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const biometricLock = '/biometric-lock';
  static const accessibility = '/accessibility';
  static const guides = '/guides';
  static const about = '/about';
  static const profile = '/profile';
  static const security = '/security';
  static const tasks = '/tasks';
  static const createTask = '/tasks/create';
  static const reminders = '/reminders';
  static const createReminder = '/reminders/create';
  static const history = '/history';
  static const settings = '/settings';
  static const notificationPreferences = '/settings/notifications';
  static const notifications = '/notifications';

  static String taskDetails(String id) => '/tasks/$id';
  static String guidedTask(String id) => '/tasks/$id/guided';
  static String editReminder(String id) => '/reminders/$id/edit';
}

final _authRoutes = {
  AppRoutes.login,
  AppRoutes.register,
  AppRoutes.forgotPassword,
};

final routerRefreshProvider = Provider<GoRouterRefreshNotifier>((ref) {
  final notifier = GoRouterRefreshNotifier(ref);
  ref.onDispose(notifier.dispose);
  return notifier;
});

final routerProvider = Provider<GoRouter>((ref) {
  final refreshListenable = ref.watch(routerRefreshProvider);

  return GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      if (authState.isLoading) return null;

      final isLoggedIn = authState.asData?.value != null;
      final location = state.matchedLocation;
      final isAuthRoute = _authRoutes.contains(location);
      final isBiometricLockRoute = location == AppRoutes.biometricLock;

      if (!isLoggedIn && !isAuthRoute && !isBiometricLockRoute) {
        return AppRoutes.login;
      }

      if (!isLoggedIn && isBiometricLockRoute) return AppRoutes.login;

      if (isLoggedIn && isAuthRoute) {
        final biometricEnabled = ref.read(biometricEnabledProvider);
        if (biometricEnabled) {
          final locked = ref.read(biometricLockedProvider);
          return locked ? AppRoutes.biometricLock : AppRoutes.home;
        }
        return AppRoutes.home;
      }

      if (isLoggedIn && !isBiometricLockRoute) {
        final biometricEnabled = ref.read(biometricEnabledProvider);
        if (biometricEnabled) {
          final locked = ref.read(biometricLockedProvider);
          if (locked) return AppRoutes.biometricLock;
        }
      }

      return null;
    },
    routes: [
      // Auth routes (fora da shell)
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.biometricLock,
        builder: (context, state) => const BiometricLockScreen(),
      ),
      GoRoute(
        path: AppRoutes.accessibility,
        builder: (context, state) => const AccessibilityScreen(),
      ),
      GoRoute(
        path: AppRoutes.notificationPreferences,
        builder: (context, state) => const NotificationPreferencesScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.guides,
        builder: (context, state) => const GuidesScreen(),
      ),
      GoRoute(
        path: AppRoutes.about,
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.security,
        builder: (context, state) => const SecurityScreen(),
      ),

      // Tarefas — rotas full-screen (fora da shell, sem bottom nav)
      GoRoute(
        path: AppRoutes.createTask,
        builder: (context, state) => const CreateTaskScreen(),
      ),
      GoRoute(
        path: AppRoutes.createReminder,
        builder: (context, state) => const CreateReminderScreen(),
      ),
      GoRoute(
        path: '/reminders/:id/edit',
        builder: (context, state) =>
            CreateReminderScreen(initial: state.extra as Reminder?),
      ),
      GoRoute(
        path: '/tasks/:id',
        builder: (context, state) =>
            TaskDetailsScreen(taskId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/tasks/:id/guided',
        builder: (context, state) =>
            GuidedTaskScreen(taskId: state.pathParameters['id']!),
      ),

      // Shell com bottom nav
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ShellScaffold(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.tasks,
                builder: (context, state) => const TaskListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.reminders,
                builder: (context, state) => const RemindersScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.history,
                builder: (context, state) => const HistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class GoRouterRefreshNotifier extends ChangeNotifier {
  GoRouterRefreshNotifier(Ref ref) {
    ref.listen(authStateProvider, (_, __) => notifyListeners());
    ref.listen(biometricLockedProvider, (_, __) => notifyListeners());
    ref.listen(biometricControllerProvider, (_, __) => notifyListeners());
  }
}
