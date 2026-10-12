class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';

  // Admin
  static const String adminDashboard = '/admin/dashboard';
  static const String adminRooms = '/admin/rooms';
  static const String adminGuests = '/admin/guests';
  static const String adminReservations = '/admin/reservations';
  static const String adminReports = '/admin/reports';
  static const String adminUsers = '/admin/users';

  // Receptionist
  static const String receptionistDashboard = '/receptionist/dashboard';
  static const String receptionistFloorPlan = '/receptionist/floor-plan';
  static const String receptionistNewReservation = '/receptionist/reservations/new';
  static const String receptionistReservationDetail = '/receptionist/reservations/:id';
  static const String receptionistGuests = '/receptionist/guests';
  static const String receptionistCheckIn = '/receptionist/check-in';
  static const String receptionistCheckOut = '/receptionist/check-out';
}
