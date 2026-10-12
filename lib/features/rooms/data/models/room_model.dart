import '../../domain/entities/room_entity.dart';

class RoomModel extends RoomEntity {
  const RoomModel({
    required super.id,
    required super.roomNumber,
    super.roomName,
    required super.roomType,
    required super.property,
    required super.capacity,
    required super.pricePerNight,
    required super.status,
    super.floorPlanX,
    super.floorPlanY,
    super.floorPlanW,
    super.floorPlanH,
    super.notes,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] as String,
      roomNumber: json['room_number'] as String,
      roomName: json['room_name'] as String?,
      roomType: _parseRoomType(json['room_type'] as String),
      property: _parseProperty(json['property'] as String),
      capacity: json['capacity'] as int,
      pricePerNight: (json['price_per_night'] as num).toDouble(),
      status: _parseStatus(json['status'] as String),
      floorPlanX: json['floor_plan_x'] != null
          ? (json['floor_plan_x'] as num).toDouble()
          : null,
      floorPlanY: json['floor_plan_y'] != null
          ? (json['floor_plan_y'] as num).toDouble()
          : null,
      floorPlanW: json['floor_plan_w'] != null
          ? (json['floor_plan_w'] as num).toDouble()
          : 1.0,
      floorPlanH: json['floor_plan_h'] != null
          ? (json['floor_plan_h'] as num).toDouble()
          : 1.0,
      notes: json['notes'] as String?,
    );
  }

  static RoomType _parseRoomType(String type) {
    switch (type) {
      case 'family_room':
        return RoomType.familyRoom;
      case 'longstay_room':
        return RoomType.longstayRoom;
      default:
        return RoomType.doubleBed;
    }
  }

  static PropertyType _parseProperty(String p) {
    return p == 'viip' ? PropertyType.viip : PropertyType.deluxe;
  }

  static RoomStatus _parseStatus(String s) {
    switch (s) {
      case 'occupied':
        return RoomStatus.occupied;
      case 'longstay':
        return RoomStatus.longstay;
      case 'maintenance':
        return RoomStatus.maintenance;
      default:
        return RoomStatus.available;
    }
  }
}
