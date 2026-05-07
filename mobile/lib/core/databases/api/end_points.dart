class EndPoints {
  // Base API URL for the backend
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  // Telegram Client ID provided by the team lead
  static const String telegramClientId = String.fromEnvironment(
    'TELEGRAM_CLIENT_ID',
    defaultValue: '8641099953',
  );

  // OAuth / OIDC Constants
  static const String discoveryUrl = 'https://oauth.telegram.org/.well-known/openid-configuration';
  static const String redirectUri = 'lms://telegram';
  static const List<String> scopes = ['openid', 'profile'];
}