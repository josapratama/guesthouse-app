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
        // Biru untuk local, oranye untuk Japan (VIP = Japan di denah)
        if (room.property == PropertyType.viip ||
            room.roomNumber.startsWith('VIP')) {
          return AppTheme.roomLongstayJapan;
        }
        // Kamar 23,24,27,30,31,33 (Blok A atas) = Japan (oranye)
        const japanRooms = ['23', '24', '27', '30', '31', '33'];
        if (japanRooms.contains(room.roomNumber)) {
          return AppTheme.roomLongstayJapan;
        }
        return AppTheme.roomLongstayLocal;
      case RoomStatus.maintenance:
        return AppTheme.roomMaintenance;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hitung batas grid dari data kamar
    final roomsWithPos =
        widget.rooms.where((r) => r.floorPlanX != null && r.floorPlanY != null).toList();

    if (roomsWithPos.isEmpty) {
      return const Center(child: Text('Data denah tidak tersedia'));
    }

    final maxX =
        roomsWithPos.map((r) => r.floorPlanX! + r.floorPlanW).reduce((a, b) => a > b ? a : b);
    final maxY =
        roomsWithPos.map((r) => r.floorPlanY! + r.floorPlanH).reduce((a, b) => a > b ? a : b);

    const cellSize = 52.0;
    const gap = 4.0;
    final planWidth = maxX * (cellSize + gap);
    final planHeight = maxY * (cellSize + gap);

    return Column(
      children: [
        // Legend
        _buildLegend(),
        const SizedBox(height: 8),
        // Floor Plan
        Expanded(
          child: InteractiveViewer(
            transformationController: _transformController,
            boundaryMargin: const EdgeInsets.all(80),
            minScale: 0.5,
            maxScale: 3.0,
            child: Center(
              child: Container(
                width: planWidth + 40,
                height: planHeight + 40,
                color: Colors.grey.shade100,
                child: Stack(
                  children: [
                    // Block labels
                    ..._buildBlockLabels(cellSize, gap),
                    // Room cells
                    ...roomsWithPos.map((room) {
                      return _RoomCell(
                        room: room,
                        cellSize: cellSize,
                        gap: gap,
                        color: _roomColor(room),
                        isSelected: widget.selectedRoom?.id == room.id,
                        onTap: widget.onRoomTap != null
                            ? () => widget.onRoomTap!(room)
                            : null,
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildBlockLabels(double cellSize, double gap) {
    // Label untuk setiap blok sesuai denah
    final labels = [
      (label: 'Blok A', x: 3.5, y: 0.1),
      (label: 'Blok D', x: 0.2, y: 4.0),
      (label: 'Blok G', x: 3.5, y: 18.2),
    ];

    return labels.map((l) {
      return Positioned(
        left: l.x * (cellSize + gap) + 20,
        top: l.y * (cellSize + gap) + 20,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            l.label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
        ),
      );
    }).toList();
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
        spacing: 16,
        runSpacing: 6,
        children: items.map((item) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: item.color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 4),
              Text(item.label,
                  style: const TextStyle(fontSize: 11, color: Colors.black87)),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ─── Room Cell Widget ─────────────────────────────────────────
class _RoomCell extends StatelessWidget {
  final RoomEntity room;
  final double cellSize;
  final double gap;
  final Color color;
  final bool isSelected;
  final VoidCallback? onTap;

  const _RoomCell({
    required this.room,
    required this.cellSize,
    required this.gap,
    required this.color,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final left = room.floorPlanX! * (cellSize + gap) + 20;
    final top = room.floorPlanY! * (cellSize + gap) + 20;
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
            color: color.withOpacity(isSelected ? 1.0 : 0.85),
            borderRadius: BorderRadius.circular(6),
            border: isSelected
                ? Border.all(color: Colors.white, width: 2.5)
                : Border.all(color: color.withOpacity(0.5), width: 1),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.6),
                      blurRadius: 8,
                      spreadRadius: 1,
                    )
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
                    fontSize: width > 60 ? 13 : 10,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (width > 55) ...[
                  Text(
                    _typeSymbol(room.roomType),
                    style: const TextStyle(color: Colors.white70, fontSize: 9),
                  ),
                ],
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
