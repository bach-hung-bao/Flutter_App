/// Pure domain entity for a Booking
class BookingEntity {
  final int id;
  final int roomId;
  final int customerId;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int nightCount;
  final int guestCount;
  final double roomUnitPrice;
  final double totalAmount;
  final String? note;
  final int status; // 0=pending,1=confirmed,2=cancelled,3=completed
  final String? cancelReason;
  final DateTime? cancelledAt;
  final DateTime createdAt;

  const BookingEntity({
    required this.id,
    required this.roomId,
    required this.customerId,
    required this.checkInDate,
    required this.checkOutDate,
    required this.nightCount,
    required this.guestCount,
    required this.roomUnitPrice,
    required this.totalAmount,
    this.note,
    required this.status,
    this.cancelReason,
    this.cancelledAt,
    required this.createdAt,
  });

  bool get isPending    => status == 0;
  bool get isConfirmed  => status == 1;
  bool get isCancelled  => status == 2;
  bool get isCompleted  => status == 3;

  String get statusLabel {
    switch (status) {
      case 0: return 'Chờ xác nhận';
      case 1: return 'Đã xác nhận';
      case 2: return 'Đã hủy';
      case 3: return 'Hoàn thành';
      default: return 'Không rõ';
    }
  }
}
