import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../rooms/presentation/providers/room_provider.dart';

class ReceptionistDashboardScreen extends ConsumerWidget {
  const ReceptionistDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final allRoomsAsync = ref.watch(roomsProvider(null));
    final availableAsync = ref.watch(availableRoomsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Resepsionis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(roomsProvider);
          ref.invalidate(availableRoomsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Text(
                'Selamat datang,',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
              Text(
                user?.name ?? 'Resepsionis',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
              ),
              const SizedBox(height: 24),

              // Stats cards
              allRoomsAsync.when(
                data: (rooms) {
                  final total = rooms.length;
                  final occupied =
                      rooms.where((r) => r.status.name == 'occupied').length;
                  final longstay =
                      rooms.where((r) => r.status.name == 'longstay').length;
                  final available =
                      rooms.where((r) => r.status.name == 'available').length;

                  return GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.6,
                    children: [
                      _StatCard(
                        label: 'Total Kamar',
                        value: '$total',
                        icon: Icons.hotel,
                        color: AppTheme.primary,
                      ),
                      _StatCard(
                        label: 'Tersedia',
                        value: '$available',
                        icon: Icons.check_circle_outline,
                        color: AppTheme.roomAvailable,
                      ),
                      _StatCard(
                        label: 'Terisi',
                        value: '$occupied',
                        icon: Icons.person,
                        color: AppTheme.roomOccupied,
                      ),
                      _StatCard(
                        label: 'Long Stay',
                        value: '$longstay',
                        icon: Icons.event_available,
                        color: AppTheme.roomLongstayJapan,
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e'),
              ),

              const SizedBox(height: 24),

              // Quick actions
              Text(
                'Menu Cepat',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _QuickActionCard(
                    label: 'Denah Kamar',
                    icon: Icons.map_outlined,
                    color: AppTheme.primary,
                    onTap: () => context.push(AppRoutes.receptionistFloorPlan),
                  ),
                  _QuickActionCard(
                    label: 'Reservasi Baru',
                    icon: Icons.add_circle_outline,
                    color: AppTheme.secondary,
                    onTap: () =>
                        context.push(AppRoutes.receptionistNewReservation),
                  ),
                  _QuickActionCard(
                    label: 'Check In',
                    icon: Icons.login,
                    color: AppTheme.roomAvailable,
                    onTap: () => context.push(AppRoutes.receptionistCheckIn),
                  ),
                  _QuickActionCard(
                    label: 'Check Out',
                    icon: Icons.logout,
                    color: AppTheme.roomOccupied,
                    onTap: () => context.push(AppRoutes.receptionistCheckOut),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
                Text(
                  label,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
