import '../../domain/entities/app_notification_entity.dart';

class AppNotificationModel extends AppNotificationEntity {
  const AppNotificationModel({
    required super.id,
    required super.type,
    required super.title,
    required super.message,
    super.referenceType,
    super.referenceId,
    required super.read,
    super.readAt,
    super.createdAt,
  });

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    return AppNotificationModel(
      id: _readInt(json['id']),
      type: json['type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      referenceType: json['referenceType']?.toString(),
      referenceId: _readNullableInt(json['referenceId']),
      read: json['read'] == true,
      readAt: _readDateTime(json['readAt']),
      createdAt: _readDateTime(json['createdAt']),
    );
  }

  static int _readInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _readNullableInt(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static DateTime? _readDateTime(Object? value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
