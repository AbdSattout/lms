import 'package:dio/dio.dart';
import 'package:lms/core/errors/error_model.dart';
//!ServerException
class ServerException implements Exception {
  final ErrorModel errorModel;
  ServerException(this.errorModel);
}
//!CacheException
class CacheException implements Exception {
  final String errorMessage;
  CacheException({required this.errorMessage});
}
class TooManyRequestsException extends ServerException {
  TooManyRequestsException(super.errorModel);
}

class BadCertificateException extends ServerException {
  BadCertificateException(super.errorModel);
}

class ConnectionTimeoutException extends ServerException {
  ConnectionTimeoutException(super.errorModel);
}

class BadResponseException extends ServerException {
  BadResponseException(super.errorModel);
}

class ReceiveTimeoutException extends ServerException {
  ReceiveTimeoutException(super.errorModel);
}

class ConnectionErrorException extends ServerException {
  ConnectionErrorException(super.errorModel);
}

class SendTimeoutException extends ServerException {
  SendTimeoutException(super.errorModel);
}

class UnauthorizedException extends ServerException {
  UnauthorizedException(super.errorModel);
}

class ForbiddenException extends ServerException {
  ForbiddenException(super.errorModel);
}

class NotFoundException extends ServerException {
  NotFoundException(super.errorModel);
}

class ConflictException extends ServerException {
  ConflictException(super.errorModel);
}

class CancelException extends ServerException {
  CancelException(super.errorModel);
}

class UnknownException extends ServerException {
  UnknownException(super.errorModel);
}

handleDioException(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionError:
      throw ConnectionErrorException(_extractError(e));
    case DioExceptionType.badCertificate:
      throw BadCertificateException(_extractError(e));
    case DioExceptionType.connectionTimeout:
      throw ConnectionTimeoutException(_extractError(e));

    case DioExceptionType.receiveTimeout:
      throw ReceiveTimeoutException(_extractError(e));

    case DioExceptionType.sendTimeout:
      throw SendTimeoutException(_extractError(e));

    case DioExceptionType.badResponse:
      _handleBadResponse(e);
      break;

    case DioExceptionType.cancel:
      throw CancelException(
        ErrorModel(
          status: 0,
          errorMessage: 'تم إلغاء تسجيل الدخول',
        ),
      );

    case DioExceptionType.unknown:
      throw UnknownException(_extractError(e));

    case DioExceptionType.transformTimeout:
      throw UnknownException(_extractError(e));
  }
}

void _handleBadResponse(DioException e) {
  final response = e.response;
  if (response == null) {
    throw UnknownException(
      ErrorModel(status: 500, errorMessage: 'استجابة غير معروفة من السيرفر'),
    );
  }

  switch (response.statusCode) {
    case 400: // Bad response
      throw BadResponseException(ErrorModel.fromJson(response.data));
    case 401: // Unauthorized
      throw UnauthorizedException(ErrorModel.fromJson(response.data));
    case 403: // Forbidden
      throw ForbiddenException(ErrorModel.fromJson(response.data));
    case 404: // Not found
      throw NotFoundException(ErrorModel.fromJson(response.data));
    case 409: // Conflict
      throw ConflictException(ErrorModel.fromJson(response.data));
    case 429: // Too many requests / Paywalled
      throw TooManyRequestsException(ErrorModel.fromJson(response.data));
    case 504: // Bad reponse
      throw BadResponseException(
        ErrorModel(
          status: 504,
          errorMessage: 'استغراق الاتصال بالسيرفر وقت طويلاً',
        ),
      );
    default:
      throw UnknownException(ErrorModel.fromJson(response.data));
  }
}

ErrorModel _extractError(DioException e) {
  if(e.response != null && e.response!.data != null) {
    try {
      return ErrorModel.fromJson(e.response!.data);
    } catch (_) {
      return ErrorModel(
        status: 0,
        errorMessage: "حدث خطأ أثناء معالجة البيانات",
      );
    }
  }
  return ErrorModel(
    status: 0,
    errorMessage: "لا يوجد اتصال بالانترنت أو السيرفر لا يستجيب",
  );
}
