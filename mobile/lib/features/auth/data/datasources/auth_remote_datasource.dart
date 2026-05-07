import 'package:flutter_appauth/flutter_appauth.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/error_model.dart';
import 'package:lms/core/databases/api/end_points.dart';
import '../models/auth_model.dart';

class AuthRemoteDataSource {
  final FlutterAppAuth appAuth;

  AuthRemoteDataSource({required this.appAuth});

  Future<AuthModel> loginWithTelegram() async {
    try {
      final AuthorizationTokenResponse? result = await appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          EndPoints.telegramClientId,
          EndPoints.redirectUri,
          discoveryUrl: EndPoints.discoveryUrl,
          scopes: EndPoints.scopes,
          promptValues: ['login'],
        ),
      );

      if (result != null && result.idToken != null) {
        return AuthModel(idToken: result.idToken!);
      } else {
        // Connection success but failed to get token
        throw ServerException(ErrorModel(status: 500, errorMessage: "Failed to get token from Telegram"));
      }
    } catch (e) {
      // Catch errors from Appauth library
      throw ServerException(ErrorModel(status: 500, errorMessage: e.toString()));
    }
  }
}