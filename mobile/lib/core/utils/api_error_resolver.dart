/// Unwraps a readable message from common exception shapes (ServerException
/// subclasses with an errorModel.errorMessage, CacheExeption with an
/// errorMessage field, or a plain .message getter). Falls back to
/// error.toString() when it isn't the unhelpful default Object.toString()
/// output ("Instance of 'ClassName'"), which is what you get from any
/// exception class that doesn't override toString() itself.
///
/// Used by feature blocs (profile, organizations, courses, ...) instead of
/// calling e.toString() directly in every catch block.
String resolveApiErrorMessage(Object error) {
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