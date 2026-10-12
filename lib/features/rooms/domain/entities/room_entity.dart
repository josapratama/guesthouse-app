enum RoomType { doubleBed, familyRoom, longstayRoom }

enum RoomStatus { available, occupied, longstay, maintenance }

enum PropertyType { deluxe, viip }

class RoomEntity {
  final String id;
  final String roomNumber;
  final String? roomName;
  final RoomType roomType;
  final PropertyType property;
  final int capacity;
  final double pricePerNight;
  final RoomStatus status;
  final double? floorPlanX;
  final double? floorPlanY;
  final double floorPlanW;
  final double floorPlanH;
  final String? notes;

  const RoomEntity({
    required this.id,
    required this.roomNumber,
    this.roomName,
    required this.roomType,
    required this.property,
    required this.capacity,
    required this.pricePerNight,
    required this.status,
    this.floorPlanX,
    this.floorPlanY,
    this.floorPlanW = 1,
    this.floorPlanH = 1,
    this.notes,
  });

  String get displayName => roomName ?? roomNumber;

  String get typeLabel {
    switch (roomType) {
      case RoomType.doubleBed:
        return 'Double Bed';
      case RoomType.familyRoom:
        return 'Family Room';
      case RoomType.longstayRoom:
        return 'Longstay Room';
    }
  }

  String get statusLabel {
    switch (status) {
      case RoomStatus.available:
        return 'Tersedia';
      case RoomStatus.occupied:
        return 'Terisi';
      case RoomStatus.longstay:
        return 'Long Stay';
      case RoomStatus.maintenance:
        return 'Maintenance';
    }
  }

  bool get isAvailable => status == RoomStatus.available;
}
