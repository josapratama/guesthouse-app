import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/room_remote_datasource.dart';
import '../../domain/entities/room_entity.dart';

final roomDataSourceProvider = Provider<RoomRemoteDataSource>((ref) {
  return RoomRemoteDataSource(ref.read(apiClientProvider));
});

// ─── Semua kamar ──────────────────────────────────────────────
final roomsProvider = FutureProvider.autoDispose
    .family<List<RoomEntity>, String?>((ref, property) async {
  final ds = ref.read(roomDataSourceProvider);
  return ds.getRooms(property: property);
});

// ─── Kamar tersedia saja ──────────────────────────────────────
final availableRoomsProvider =
    FutureProvider.autoDispose<List<RoomEntity>>((ref) async {
  final ds = ref.read(roomDataSourceProvider);
  return ds.getRooms(status: 'available');
});

// ─── Selected room di floor plan ─────────────────────────────
final selectedRoomProvider = StateProvider<RoomEntity?>((ref) => null);
