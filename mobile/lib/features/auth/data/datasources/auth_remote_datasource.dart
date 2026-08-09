import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lms/core/databases/api/end_points.dart';
import '../../../../core/databases/api/api_consumer.dart';
import '../../../../core/errors/error_model.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/auth_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthModel> loginWithTelegram();
  Future<AuthModel> loginWithGoogle();
  Future<void> requestEmailOtp(String email);
  Future<AuthModel> verifyEmailOtp({
    required String email,
    required String otp,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FlutterAppAuth appAuth;
  final GoogleSignIn googleSignIn;
  final ApiConsumer apiConsumer;
  bool _googleSignInInitialized = false;

  AuthRemoteDataSourceImpl({
    required this.appAuth,
    required this.googleSignIn,
    required this.apiConsumer,
  });

  @override
  Future<AuthModel> loginWithTelegram() async {
    try {
      final result = await appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          EndPoints.telegramClientId,
          EndPoints.redirectUri,
          discoveryUrl: EndPoints.discoveryUrl,
          scopes: EndPoints.scopes,
          promptValues: ['login'],
        ),
      );

      if (result.idToken != null) {
        final response = await apiConsumer.post(
          EndPoints.login,
          data: {"idToken": result.idToken},
        );

        return AuthModel.fromJson(response);
      } else {
        throw Exception("Failed to obtain idToken from Telegram");
      }
    } on FlutterAppAuthUserCancelledException {
      throw CancelException(
        ErrorModel(status: 0, errorMessage: "تم إلغاء تسجيل الدخول"),
      );
    }
  }

  @override
  Future<AuthModel> loginWithGoogle() async {
    try {
      final account = await _authenticateWithGoogle();
      final idToken = account.authentication.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw ServerException(
          ErrorModel(
            status: 0,
            errorMessage: "Failed to obtain idToken from Google",
          ),
        );
      }

      final response = await apiConsumer.post(
        EndPoints.googleLogin,
        data: {"idToken": idToken},
      );

      return AuthModel.fromJson(response);
    } on GoogleSignInException catch (e) {
      final description = e.description?.trim();
      final details = description == null || description.isEmpty
          ? e.code.name
          : '${e.code.name}: $description';

      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw CancelException(
          ErrorModel(status: 0, errorMessage: "تم إلغاء تسجيل الدخول"),
        );
      }

      throw ServerException(
        ErrorModel(status: 0, errorMessage: "Google sign-in failed ($details)"),
      );
    }
  }

  @override
  Future<void> requestEmailOtp(String email) async {
    await apiConsumer.post(EndPoints.requestEmailOtp, data: {'email': email});
  }

  @override
  Future<AuthModel> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    final response = await apiConsumer.post(
      EndPoints.verifyEmailOtp,
      data: {'email': email, 'otp': otp},
    );

    return AuthModel.fromJson(response);
  }

  Future<GoogleSignInAccount> _authenticateWithGoogle() async {
    await _ensureGoogleSignInInitialized();

    if (!googleSignIn.supportsAuthenticate()) {
      throw ServerException(
        ErrorModel(
          status: 0,
          errorMessage: "Google sign-in is not supported on this platform",
        ),
      );
    }

    return googleSignIn.authenticate();
  }

  Future<void> _ensureGoogleSignInInitialized() async {
    if (_googleSignInInitialized) return;

    if (EndPoints.googleClientId.isEmpty) {
      throw ServerException(
        ErrorModel(
          status: 0,
          errorMessage: "Missing GOOGLE_CLIENT_ID for Google sign-in",
        ),
      );
    }

    await googleSignIn.initialize(serverClientId: EndPoints.googleClientId);
    _googleSignInInitialized = true;
  }
}
