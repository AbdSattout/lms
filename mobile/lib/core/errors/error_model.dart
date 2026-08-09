class ErrorModel {
  final int status;
  final String errorMessage;

  ErrorModel({required this.status, required this.errorMessage});

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

    return ErrorModel(
      errorMessage: _normalizeMessage(rawMessage?.toString()),
      status: _readStatus(jsonData["status"]),
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
      _ => normalized,
    };
  }
}
