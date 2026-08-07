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
      'auth/login/telegram';

  static const String profile =
      'profile/me';

  static const String updateProfilePicture =
      'users/me/picture';

  // Courses
  static const String courses = 'courses';

  static String courseById(int id) => 'courses/$id';

  static String enrollInCourse(int id) => 'courses/$id/enroll';

  static const String myEnrollments = 'courses/me/enrollments';

  static String placementTest(int courseId) =>
      'mobile/courses/$courseId/placement-test';

  static String skipPlacementTest(int courseId) =>
      'mobile/courses/$courseId/placement-test/skip';

  // Organizations
  static const String organizations = 'organizations';
  static String organizationBySlug(String slug) => 'organizations/$slug';
  static String organizationJoin(String slug) => 'organizations/$slug/join';
  static String organizationLeave(String slug) => 'organizations/$slug/leave';
  static String deleteOrganizationDashboard(String slug) => 'organizations/$slug/leave';

  static String organizationCourses(String orgSlug) =>
      'organizations/$orgSlug/courses';

  static String courseBySlug({
    required String orgSlug,
    required String courseSlug,
  }) =>
      'organizations/$orgSlug/courses/$courseSlug';
  // Blocks
  static String blockContent(int blockId) => 'blocks/$blockId';
  static String submitBlockAnswer(int blockId) => 'blocks/$blockId/submit';

  // Gamification
  static const String gamificationMe = 'gamification/me';
  static const String gamificationStreak = 'gamification/streak';
  static const String gamificationActivity = 'gamification/activity';
  static const String gamificationScoreboard = 'gamification/scoreboard';
}