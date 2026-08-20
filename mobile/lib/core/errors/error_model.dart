import '../utils/date_time_utils.dart';

const kUserBannedMessage = 'تم حظر حسابك، لا يمكنك تسجيل الدخول. تواصل مع الدعم إذا كنت تعتقد أن هذا خطأ.';

class ErrorModel {
  final int status;
  final String errorMessage;
  final DateTime? mutedUntil;
  final String? muteReason;

  ErrorModel({
    required this.status,
    required this.errorMessage,
    this.mutedUntil,
    this.muteReason,
  });

  factory ErrorModel.fromJson(Object? jsonData) {
    if (jsonData is! Map<String, dynamic>) {
      return ErrorModel(
        status: 0,
        errorMessage: _normalizeMessage(jsonData?.toString()),
      );
    }

    final rawMessage =
        jsonData["error"] ??
        jsonData["message"] ??
        jsonData["Message"] ??
        jsonData["errorMessage"] ??
        jsonData["detail"];

    final reason = jsonData["reason"]?.toString().trim();
    final code = jsonData["code"]?.toString();

    if (code == "USER_BANNED") {
      return ErrorModel(
        errorMessage: kUserBannedMessage,
        status: _readStatus(jsonData["status"]),
      );
    }

    return ErrorModel(
      errorMessage: _normalizeMessage(rawMessage?.toString()),
      status: _readStatus(jsonData["status"]),
      mutedUntil: parseApiDateTime(jsonData["mutedUntil"]),
      muteReason: (reason == null || reason.isEmpty) ? null : reason,
    );
  }

  static int _readStatus(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _normalizeMessage(String? message) {
    final normalized = message?.trim();
    if (normalized == null || normalized.isEmpty) {
      return "حدث خطأ غير متوقع";
    }

    return switch (normalized) {
      "Email is already linked to another account" =>
        "هذا البريد الإلكتروني مرتبط بحساب آخر",
      "Email is already set and cannot be changed" =>
        "تم ربط بريد تسجيل الدخول مسبقاً ولا يمكن تغييره",
      "User is banned" => kUserBannedMessage,
      _ => normalized,
    };
  }
}
