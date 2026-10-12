import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/room_entity.dart';
import '../providers/room_provider.dart';
import '../widgets/floor_plan_widget.dart';

class FloorPlanScreen extends ConsumerStatefulWidget {
  const FloorPlanScreen({super.key});

  @override
  ConsumerState<FloorPlanScreen> createState() => _FloorPlanScreenState();
}

class _FloorPlanScreenState extends ConsumerState<FloorPlanScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onRoomTap(RoomEntity room, BuildContext context) {
    ref.read(selectedRoomProvider.notifier).state = room;
    _showRoomDetail(context, room);
  }

  void _showRoomDetail(BuildContext context, RoomEntity room) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _RoomDetailSheet(
        room: room,
        onBook: room.isAvailable
            ? () {
                Navigator.pop(ctx);
                context.push(
                  AppRoutes.receptionistNewReservation,
                  extra: room,
                );
              }
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Denah Kamar'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Guest House Deluxe'),
            Tab(text: 'VIIP (Accasia)'),
          ],
        ),
        actions: [
          // Filter legend info
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showLegendDialog(context),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _FloorPlanTab(property: 'deluxe', onRoomTap: _onRoomTap),
          _FloorPlanTab(property: 'viip', onRoomTap: _onRoomTap),
        ],
      ),
    );
  }

  void _showLegendDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keterangan Kamar'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _legendItem('*', 'Double Bed (1-2 orang)'),
            _legendItem('**', 'Family Room (1-3 orang)'),
            _legendItem('***', 'Longstay / Big Room'),
            const Divider(),
            _colorLegend(AppTheme.roomAvailable, 'Tersedia'),
            _colorLegend(AppTheme.roomOccupied, 'Terisi'),
            _colorLegend(AppTheme.roomLongstayJapan, 'Long Stay (Japan)'),
            _colorLegend(AppTheme.roomLongstayLocal, 'Long Stay (Lokal)'),
            _colorLegend(AppTheme.roomMaintenance, 'Maintenance'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(String symbol, String desc) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 36,
              alignment: Alignment.center,
              child: Text(symbol,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
            Text(desc),
          ],
        ),
      );

  Widget _colorLegend(Color color, String label) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 13)),
          ],
        ),
      );
}

// ─── Tab per property ─────────────────────────────────────────
class _FloorPlanTab extends ConsumerWidget {
  final String property;
  final void Function(RoomEntity, BuildContext) onRoomTap;

  const _FloorPlanTab({required this.property, required this.onRoomTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(roomsProvider(property));
    final selectedRoom = ref.watch(selectedRoomProvider);

    return roomsAsync.when(
      data: (rooms) => FloorPlanWidget(
        rooms: rooms,
        selectedRoom: selectedRoom,
        onRoomTap: (room) => onRoomTap(room, context),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
            const SizedBox(height: 16),
            Text('Gagal memuat denah: $e'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(roomsProvider(property)),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Room Detail Bottom Sheet ─────────────────────────────────
class _RoomDetailSheet extends StatelessWidget {
  final RoomEntity room;
  final VoidCallback? onBook;

  const _RoomDetailSheet({required this.room, this.onBook});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(room.status);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    room.roomNumber,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.displayName,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      room.typeLabel,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  room.statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          _infoRow(Icons.people_outlined, 'Kapasitas', '${room.capacity} orang'),
          _infoRow(Icons.hotel_outlined, 'Tipe', room.typeLabel),
          _infoRow(Icons.apartment_outlined, 'Properti',
              room.property == PropertyType.deluxe
                  ? 'Guest House Deluxe'
                  : 'Guest House VIIP'),
          if (room.pricePerNight > 0)
            _infoRow(Icons.payments_outlined, 'Harga/malam',
                'Rp ${_formatCurrency(room.pricePerNight)}'),

          if (room.notes != null) ...[
            const SizedBox(height: 8),
            _infoRow(Icons.notes_outlined, 'Catatan', room.notes!),
          ],

          const SizedBox(height: 24),

          if (onBook != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onBook,
                icon: const Icon(Icons.book_online),
                label: const Text('Buat Reservasi'),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: null,
                child: Text('Kamar ${room.statusLabel}'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey.shade600),
            const SizedBox(width: 12),
            Text(label,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            const Spacer(),
            Text(value,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
          ],
        ),
      );

  Color _statusColor(RoomStatus status) {
    switch (status) {
      case RoomStatus.available:
        return AppTheme.roomAvailable;
      case RoomStatus.occupied:
        return AppTheme.roomOccupied;
      case RoomStatus.longstay:
        return AppTheme.roomLongstayJapan;
      case RoomStatus.maintenance:
        return AppTheme.roomMaintenance;
    }
  }

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
  }
}
