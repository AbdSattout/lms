class EndPoints {
  // Base API URL for the backend
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://lms.koyeb.app/',
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

  // Courses
  static const String courses = 'courses';

  static String courseById(int id) => 'courses/$id';

  static String enrollInCourse(int id) => 'courses/$id/enroll';

  // Organizations
  static const String organizations = 'organizations';

  static String organizationBySlug(String slug) => 'organizations/$slug';

  static String organizationCourses(String orgSlug) =>
      'organizations/$orgSlug/courses';

  static String courseBySlug({
    required String orgSlug,
    required String courseSlug,
  }) =>
      'organizations/$orgSlug/courses/$courseSlug';
}