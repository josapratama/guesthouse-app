import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/dashboard/presentation/screens/admin_dashboard_screen.dart';
import '../../features/dashboard/presentation/screens/receptionist_dashboard_screen.dart';
import '../../features/reservations/presentation/screens/new_reservation_screen.dart';
import '../../features/rooms/domain/entities/room_entity.dart';
import '../../features/rooms/presentation/screens/floor_plan_screen.dart';
import '../constants/app_routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: AppRoutes.login,
    redirect: (context, state) {
      final isLoggedIn = authState.isAuthenticated;
      final isLoginRoute =
          state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.splash;

      if (!isLoggedIn && !isLoginRoute) return AppRoutes.login;
      if (isLoggedIn && isLoginRoute) {
        final user = authState.user!;
        if (user.isAdmin) return AppRoutes.adminDashboard;
        return AppRoutes.receptionistDashboard;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      // Admin routes
      GoRoute(
        path: AppRoutes.adminDashboard,
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      // Receptionist routes
      GoRoute(
        path: AppRoutes.receptionistDashboard,
        builder: (context, state) => const ReceptionistDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.receptionistFloorPlan,
        builder: (context, state) => const FloorPlanScreen(),
      ),
      GoRoute(
        path: AppRoutes.receptionistNewReservation,
        builder: (context, state) {
          final room = state.extra as RoomEntity?;
          return NewReservationScreen(preselectedRoom: room);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Halaman tidak ditemukan: ${state.error}')),
    ),
  );
});
