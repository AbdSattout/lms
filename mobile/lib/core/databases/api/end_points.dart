class EndPoints {
  // Base API URL for the backend
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://10.0.2.2:8080/',
  );

  // Telegram Client ID
  static const String telegramClientId = String.fromEnvironment(
    'TELEGRAM_CLIENT_ID',
    defaultValue: '8641099953',
  );

  // OAuth / OIDC Constants
  static const String discoveryUrl = 'https://oauth.telegram.org/.well-known/openid-configuration';
  static const String redirectUri = 'lms://telegram';
  static const List<String> scopes = ['openid', 'profile'];

  // Paths
  static const String login =
      'auth/login';

  static const String profile =
      'profile/me';

  static const String updateProfilePicture =
      'users/me/picture';
}