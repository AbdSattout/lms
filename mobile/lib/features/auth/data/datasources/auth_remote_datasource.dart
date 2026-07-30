import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:lms/core/databases/api/end_points.dart';
import '../../../../core/databases/api/api_consumer.dart';
import '../../../../core/errors/error_model.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/auth_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthModel> loginWithTelegram();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FlutterAppAuth appAuth;
  final ApiConsumer apiConsumer;

  AuthRemoteDataSourceImpl({required this.appAuth, required this.apiConsumer});

  @override
  @override
  Future<AuthModel> loginWithTelegram() async {
    try {
      print("Auth Start");

      final AuthorizationTokenResponse? result =
      await appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          EndPoints.telegramClientId,
          EndPoints.redirectUri,
          discoveryUrl: EndPoints.discoveryUrl,
          scopes: EndPoints.scopes,
          promptValues: ['login'],
        ),
      );

      print("Auth Finished");

      if (result != null && result.idToken != null) {
        final response = await apiConsumer.post(
          EndPoints.login,
          data: {
            "idToken": result.idToken,
          },
        );

        return AuthModel.fromJson(response);
      } else {
        throw Exception("Failed to obtain idToken from Telegram");
      }
    } on FlutterAppAuthUserCancelledException {
      throw CancelException(
        ErrorModel(
          status: 0,
          errorMessage: "تم إلغاء تسجيل الدخول",
        ),
      );
    }
  }}