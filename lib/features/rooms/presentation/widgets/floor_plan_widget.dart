import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/room_entity.dart';

class FloorPlanWidget extends StatefulWidget {
  final List<RoomEntity> rooms;
  final RoomEntity? selectedRoom;
  final void Function(RoomEntity room)? onRoomTap;

  const FloorPlanWidget({
    super.key,
    required this.rooms,
    this.selectedRoom,
    this.onRoomTap,
  });

  @override
  State<FloorPlanWidget> createState() => _FloorPlanWidgetState();
}

class _FloorPlanWidgetState extends State<FloorPlanWidget> {
  final TransformationController _transformController =
      TransformationController();

  // Kamar Blok A atas yang long stay Japan (oranye)
  static const _japanRooms = {'23', '27', '31', '33'};
  // Kamar Blok G yang long stay Japan
  static const _japanRoomsG = {'54', '55'};
  // Kamar long stay Local (biru)
  static const _localRooms = {'24', '30', '61', '62'};

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  Color _roomColor(RoomEntity room) {
    switch (room.status) {
      case RoomStatus.available:
        return AppTheme.roomAvailable;
      case RoomStatus.occupied:
        return AppTheme.roomOccupied;
      case RoomStatus.longstay:
        if (_japanRooms.contains(room.roomNumber) ||
            _japanRoomsG.contains(room.roomNumber)) {
          return AppTheme.roomLongstayJapan; // Oranye
        }
        if (_localRooms.contains(room.roomNumber)) {
          return AppTheme.roomLongstayLocal; // Biru
        }
        return AppTheme.roomLongstayJapan;
      case RoomStatus.maintenance:
        return AppTheme.roomMaintenance;
    }
  }

  @override
  Widget build(BuildContext context) {
    final roomsWithPos = widget.rooms
        .where((r) => r.floorPlanX != null && r.floorPlanY != null)
        .toList();

    if (roomsWithPos.isEmpty) {
      return const Center(child: Text('Data denah tidak tersedia'));
    }

    const cellSize = 52.0;
    const gap = 4.0;
    const padding = 16.0;

    // Grid size tetap sesuai denah (10 kolom x 21 baris)
    const gridCols = 11.0;
    const gridRows = 22.0;
    final planWidth = gridCols * (cellSize + gap) + padding * 2;
    final planHeight = gridRows * (cellSize + gap) + padding * 2;

    return Column(
      children: [
        _buildLegend(),
        Expanded(
          child: InteractiveViewer(
            transformationController: _transformController,
            boundaryMargin: const EdgeInsets.all(100),
            minScale: 0.4,
            maxScale: 3.0,
            child: Container(
              width: planWidth,
              height: planHeight,
              color: const Color(0xFFEEF0F5),
              child: Stack(
                children: [
                  // ── Area labels ──────────────────────────────
                  ..._buildAreaLabels(cellSize, gap, padding),
                  // ── Corridor lines ────────────────────────────
                  ..._buildCorridors(cellSize, gap, padding),
                  // ── Room cells ───────────────────────────────
                  ...roomsWithPos.map(
                    (room) => _RoomCell(
                      room: room,
                      cellSize: cellSize,
                      gap: gap,
                      padding: padding,
                      color: _roomColor(room),
                      isSelected: widget.selectedRoom?.id == room.id,
                      onTap: widget.onRoomTap != null
                          ? () => widget.onRoomTap!(room)
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildAreaLabels(double cs, double gap, double pad) {
    // [label, x, y, width_cells, height_cells, color]
    final areas = [
      // Blok A label
      _AreaLabel(
        'Koridor Blok A',
        3,
        0,
        7,
        2,
        AppTheme.primary.withValues(alpha: 0.08),
      ),
      // Lobby B
      _AreaLabel('Lobby B', 0, 0, 2.5, 1, Colors.blue.shade50),
      // Blok D atas label (kiri)
      _AreaLabel('Blok D', 0, 1, 2, 9, Colors.green.shade50),
      // Lobby / Office (gap Y=9)
      _AreaLabel('Lobby & Office', 0, 9, 2, 1, Colors.orange.shade50),
      // Blok D bawah
      _AreaLabel('', 0, 10, 2, 8, Colors.green.shade50),
      // Server / Panel (gap Y=18)
      _AreaLabel('Server MID', 0, 18, 2, 1, Colors.grey.shade200),
      // Blok G label
      _AreaLabel(
        'Koridor Blok G',
        2,
        19,
        7,
        2,
        AppTheme.primary.withValues(alpha: 0.08),
      ),
      // Lobby F
      _AreaLabel('Lobby F', 0, 19, 2, 2, Colors.blue.shade50),
    ];

    return areas.map((a) {
      final left = a.x * (cs + gap) + pad;
      final top = a.y * (cs + gap) + pad;
      final width = a.w * (cs + gap) - gap;
      final height = a.h * (cs + gap) - gap;
      return Positioned(
        left: left,
        top: top,
        width: width,
        height: height,
        child: Container(
          decoration: BoxDecoration(
            color: a.color,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey.shade300, width: 0.5),
          ),
          alignment: Alignment.center,
          child: a.label.isNotEmpty
              ? Text(
                  a.label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                )
              : null,
        ),
      );
    }).toList();
  }

  List<Widget> _buildCorridors(double cs, double gap, double pad) {
    // Koridor vertikal antara kolom 0 dan 1 di Blok D (X=2 adalah gap koridor)
    // Visualisasi sebagai label teks vertikal
    final corridorTop = 1 * (cs + gap) + pad;
    final corridorHeight = 8 * (cs + gap);
    final corridorLeft = 2 * (cs + gap) + pad;

    final corridorTop2 = 10 * (cs + gap) + pad;
    final corridorHeight2 = 8 * (cs + gap);

    return [
      // Koridor Blok D atas
      Positioned(
        left: corridorLeft - 2,
        top: corridorTop,
        width: cs * 0.5,
        height: corridorHeight,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(3),
          ),
          alignment: Alignment.center,
          child: RotatedBox(
            quarterTurns: 1,
            child: Text(
              'KORIDOR',
              style: TextStyle(
                fontSize: 8,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ),
      // Koridor Blok D bawah
      Positioned(
        left: corridorLeft - 2,
        top: corridorTop2,
        width: cs * 0.5,
        height: corridorHeight2,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(3),
          ),
          alignment: Alignment.center,
          child: RotatedBox(
            quarterTurns: 1,
            child: Text(
              'KORIDOR',
              style: TextStyle(
                fontSize: 8,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildLegend() {
    final items = [
      (color: AppTheme.roomAvailable, label: 'Tersedia'),
      (color: AppTheme.roomOccupied, label: 'Terisi'),
      (color: AppTheme.roomLongstayJapan, label: 'Long Stay (Japan)'),
      (color: AppTheme.roomLongstayLocal, label: 'Long Stay (Lokal)'),
      (color: AppTheme.roomMaintenance, label: 'Maintenance'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.white,
      child: Wrap(
        spacing: 12,
        runSpacing: 6,
        children: items.map((item) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: item.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                item.label,
                style: const TextStyle(fontSize: 10, color: Colors.black87),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ─── Helper data class untuk area label ──────────────────────
class _AreaLabel {
  final String label;
  final double x, y, w, h;
  final Color color;
  _AreaLabel(this.label, this.x, this.y, this.w, this.h, this.color);
}

// ─── Room Cell ────────────────────────────────────────────────
class _RoomCell extends StatelessWidget {
  final RoomEntity room;
  final double cellSize;
  final double gap;
  final double padding;
  final Color color;
  final bool isSelected;
  final VoidCallback? onTap;

  const _RoomCell({
    required this.room,
    required this.cellSize,
    required this.gap,
    required this.padding,
    required this.color,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final left = room.floorPlanX! * (cellSize + gap) + padding;
    final top = room.floorPlanY! * (cellSize + gap) + padding;
    final width = room.floorPlanW * (cellSize + gap) - gap;
    final height = room.floorPlanH * (cellSize + gap) - gap;

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isSelected ? 1.0 : 0.9),
            borderRadius: BorderRadius.circular(6),
            border: isSelected
                ? Border.all(color: Colors.white, width: 2.5)
                : Border.all(color: color.withValues(alpha: 0.4), width: 1),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.5),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  room.roomNumber,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: width > 80 ? 14 : 11,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _typeSymbol(room.roomType),
                  style: const TextStyle(color: Colors.white70, fontSize: 9),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _typeSymbol(RoomType type) {
    switch (type) {
      case RoomType.doubleBed:
        return '*';
      case RoomType.familyRoom:
        return '**';
      case RoomType.longstayRoom:
        return '***';
    }
  }
}
