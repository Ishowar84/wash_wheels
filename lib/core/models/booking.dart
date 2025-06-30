enum BookingStatus { pending, inProgress, completed, cancelled }

class Booking {
  final String id;
  final String serviceName;
  final DateTime date;
  final BookingStatus status;
  final double price;

  Booking({
    required this.id,
    required this.serviceName,
    required this.date,
    required this.status,
    required this.price,
  });
}