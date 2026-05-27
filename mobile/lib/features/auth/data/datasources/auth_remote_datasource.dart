import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:lms/core/databases/api/end_points.dart';
import '../../../../core/databases/api/api_consumer.dart';
import '../models/auth_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthModel> loginWithTelegram();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FlutterAppAuth appAuth;
  final ApiConsumer apiConsumer;

  AuthRemoteDataSourceImpl({required this.appAuth, required this.apiConsumer});

  @override
  Future<AuthModel> loginWithTelegram() async {
    // Step 1: Authenticate with Telegram OIDC to get idToken
    final AuthorizationTokenResponse? result = await appAuth
        .authorizeAndExchangeCode(
          AuthorizationTokenRequest(
            EndPoints.telegramClientId,
            EndPoints.redirectUri,
            discoveryUrl: EndPoints.discoveryUrl,
            scopes: EndPoints.scopes,
            promptValues: ['login'],
          ),
        );

    if (result != null && result.idToken != null) {
      // Step 2: Send idToken to Spring Boot Backend
      // http://10.0.2.2:8080 for Android Emulator
      final response = await apiConsumer.post(
        'auth/login',
        data: {"idToken": result.idToken},
      );
      // Step 3: Parse the backend response (Token + User Info)
      return AuthModel.fromJson(response);
    } else {
      throw Exception("Failed to obtain idToken from Telegram");
    }
  }
}
