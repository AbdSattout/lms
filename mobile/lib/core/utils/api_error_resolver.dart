import '../errors/exceptions.dart';

String resolveApiErrorMessage(Object error) {
  if (error is TooManyRequestsException) {
    return 'لقد وصلت إلى الحد الأقصى المسموح به لهذه الميزة. يرجى ترقية خطتك للمتابعة.';
  }

  final raw = error.toString();
  if (!raw.startsWith('Instance of')) return raw;

  try {
    final dynamic e = error;
    final dynamic model = e.errorModel;
    if (model != null) {
      final dynamic msg = model.errorMessage;
      if (msg != null) return msg.toString();
    }
  } catch (_) {}

  try {
    final dynamic e = error;
    final dynamic msg = e.errorMessage;
    if (msg != null) return msg.toString();
  } catch (_) {}

  try {
    final dynamic e = error;
    final dynamic msg = e.message;
    if (msg != null) return msg.toString();
  } catch (_) {}

  return 'حدث خطأ غير متوقع، حاول مرة أخرى (${error.runtimeType})';
}