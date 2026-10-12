import '../../domain/entities/reservation_entity.dart';

class ReservationModel extends ReservationEntity {
  const ReservationModel({
    required super.id,
    required super.reservationNo,
    required super.guestId,
    required super.guestName,
    required super.roomId,
    required super.roomNumber,
    required super.roomName,
    super.companyName,
    super.receptionistId,
    required super.checkInDate,
    required super.checkOutDate,
    super.actualCheckIn,
    super.actualCheckOut,
    required super.totalDays,
    super.occupiedRoom,
    required super.status,
    super.remark,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      id: json['id'] as String,
      reservationNo: json['reservation_no'] as String,
      guestId: json['guest_id'] as String,
      guestName: json['guest_name'] as String? ?? '',
      roomId: json['room_id'] as String,
      roomNumber: json['room_number'] as String? ?? '',
      roomName: json['room_name'] as String? ?? '',
      companyName: json['company_name'] as String?,
      receptionistId: json['receptionist_id'] as String?,
      checkInDate: DateTime.parse(json['check_in_date'] as String),
      checkOutDate: DateTime.parse(json['check_out_date'] as String),
      actualCheckIn: json['actual_check_in'] != null
          ? DateTime.parse(json['actual_check_in'] as String)
          : null,
      actualCheckOut: json['actual_check_out'] != null
          ? DateTime.parse(json['actual_check_out'] as String)
          : null,
      totalDays: json['total_days'] as int? ?? 0,
      occupiedRoom: json['occupied_room'] as int? ?? 1,
      status: _parseStatus(json['status'] as String),
      remark: json['remark'] as String?,
    );
  }

  Map<String, dynamic> toCreateJson() => {
        'guest_id': guestId,
        'room_id': roomId,
        'company_id': null,
        'check_in_date': checkInDate.toIso8601String().split('T')[0],
        'check_out_date': checkOutDate.toIso8601String().split('T')[0],
        'occupied_room': occupiedRoom,
        'remark': remark,
      };

  static ReservationStatus _parseStatus(String s) {
    switch (s) {
      case 'confirmed':
        return ReservationStatus.confirmed;
      case 'checked_in':
        return ReservationStatus.checkedIn;
      case 'checked_out':
        return ReservationStatus.checkedOut;
      case 'cancelled':
        return ReservationStatus.cancelled;
      default:
        return ReservationStatus.pending;
    }
  }
}
