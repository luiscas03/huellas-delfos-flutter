import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/recover_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/journey/presentation/my_journey_screen.dart';
import '../../features/manual_upload/presentation/manual_upload_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/records/presentation/identify_patient_screen.dart';
import '../../features/records/presentation/identify_patient_filled_screen.dart';
import '../../features/records/presentation/pre_visit_stepper_screen.dart';
import '../../features/records/presentation/pre_visit_detail_a_screen.dart';
import '../../features/records/presentation/pre_visit_detail_b_screen.dart';
import '../../features/records/presentation/consent_screen.dart';
import '../../features/records/presentation/recording_active_screen.dart';
import '../../features/records/presentation/recording_inactive_screen.dart';
import '../../features/records/presentation/recording_segments_screen.dart';
import '../../features/records/presentation/closure_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import 'app_routes.dart';
import 'auth_router_notifier.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authRouterNotifierProvider);
  return GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final loggedIn = authNotifier.isLoggedIn;
      final loggingIn = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register ||
          state.matchedLocation == AppRoutes.recover;
      if (!loggedIn && !loggingIn) return AppRoutes.login;
      if (loggedIn && loggingIn) return AppRoutes.dashboard;
      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginScreen()),
      GoRoute(path: AppRoutes.register, builder: (_, __) => const RegisterScreen()),
      GoRoute(path: AppRoutes.recover, builder: (_, __) => const RecoverScreen()),
      GoRoute(path: AppRoutes.dashboard, builder: (_, __) => const DashboardScreen()),
      GoRoute(path: AppRoutes.myJourney, builder: (_, __) => const MyJourneyScreen()),
      GoRoute(path: AppRoutes.manualUpload, builder: (_, __) => const ManualUploadScreen()),
      GoRoute(path: AppRoutes.profile, builder: (_, __) => const ProfileScreen()),
      GoRoute(path: AppRoutes.history, builder: (_, __) => const HistoryScreen()),
      GoRoute(path: AppRoutes.identify, builder: (_, __) => const IdentifyPatientScreen()),
      GoRoute(path: AppRoutes.identifyFilled, builder: (_, __) => const IdentifyPatientFilledScreen()),
      GoRoute(path: AppRoutes.preVisitStepper, builder: (_, __) => const PreVisitStepperScreen()),
      GoRoute(path: AppRoutes.preVisitDetailA, builder: (_, __) => const PreVisitDetailAScreen()),
      GoRoute(path: AppRoutes.preVisitDetailB, builder: (_, __) => const PreVisitDetailBScreen()),
      GoRoute(path: AppRoutes.consent, builder: (_, __) => const ConsentScreen()),
      GoRoute(path: AppRoutes.recordingActive, builder: (_, __) => const RecordingActiveScreen()),
      GoRoute(path: AppRoutes.recordingInactive, builder: (_, __) => const RecordingInactiveScreen()),
      GoRoute(path: AppRoutes.recordingSegments, builder: (_, __) => const RecordingSegmentsScreen()),
      GoRoute(path: AppRoutes.closure, builder: (_, __) => const ClosureScreen()),
      GoRoute(path: AppRoutes.settings, builder: (_, __) => const SettingsScreen()),
    ],
  );
});
