enum ReservationStatus {
  pending,
  confirmed,
  checkedIn,
  checkedOut,
  cancelled,
}

class ReservationEntity {
  final String id;
  final String reservationNo;
  final String guestId;
  final String guestName;
  final String roomId;
  final String roomNumber;
  final String roomName;
  final String? companyName;
  final String? receptionistId;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final DateTime? actualCheckIn;
  final DateTime? actualCheckOut;
  final int totalDays;
  final int occupiedRoom;
  final ReservationStatus status;
  final String? remark;

  const ReservationEntity({
    required this.id,
    required this.reservationNo,
    required this.guestId,
    required this.guestName,
    required this.roomId,
    required this.roomNumber,
    required this.roomName,
    this.companyName,
    this.receptionistId,
    required this.checkInDate,
    required this.checkOutDate,
    this.actualCheckIn,
    this.actualCheckOut,
    required this.totalDays,
    this.occupiedRoom = 1,
    required this.status,
    this.remark,
  });

  String get statusLabel {
    switch (status) {
      case ReservationStatus.pending:
        return 'Menunggu';
      case ReservationStatus.confirmed:
        return 'Dikonfirmasi';
      case ReservationStatus.checkedIn:
        return 'Check In';
      case ReservationStatus.checkedOut:
        return 'Check Out';
      case ReservationStatus.cancelled:
        return 'Dibatalkan';
    }
  }

  bool get canCheckIn =>
      status == ReservationStatus.confirmed ||
      status == ReservationStatus.pending;
  bool get canCheckOut => status == ReservationStatus.checkedIn;
}
