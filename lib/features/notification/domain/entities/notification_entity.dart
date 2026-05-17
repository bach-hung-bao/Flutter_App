class NotificationEntity {
  final int id;
  final int userId;
  final String? title;
  final String? message;
  final int type;
  final bool isRead;
  final DateTime createdAt;
  final int? relatedId;
  final String? relatedTable;

  const NotificationEntity({
    required this.id,
    required this.userId,
    this.title,
    this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.relatedId,
    this.relatedTable,
  });

  factory NotificationEntity.fromJson(Map<String, dynamic> json) {
    return NotificationEntity(
      id: json['id'] as int? ?? 0,
      userId: json['userId'] as int? ?? 0,
      title: json['title'] as String?,
      message: json['message'] as String?,
      type: json['type'] as int? ?? 0,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      relatedId: json['relatedId'] as int?,
      relatedTable: json['relatedTable'] as String?,
    );
  }
}
