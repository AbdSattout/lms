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

  // Google web OAuth client ID used as the ID-token audience by the backend.
  static const String googleClientId = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
    defaultValue:
        '326110699388-969maarsvt92vapdsn67b60cj3ou56q5.apps.googleusercontent.com',
  );

  // OAuth / OIDC Constants
  static const String discoveryUrl =
      'https://oauth.telegram.org/.well-known/openid-configuration';
  static const String redirectUri = 'lms://telegram';
  static const List<String> scopes = ['openid', 'profile'];

  // Paths
  static const String login = 'auth/login/telegram';
  static const String googleLogin = 'auth/login/google';

  static const String requestEmailOtp = 'auth/login/email/request-otp';

  static const String verifyEmailOtp = 'auth/login/email/verify-otp';

  static const String profile = 'profile/me';

  static const String currentUser = 'users/me';

  static const String updateProfilePicture = 'users/me/picture';

  static const String requestAccountEmailOtp = 'users/me/email/request-otp';

  static const String verifyAccountEmailOtp = 'users/me/email/verify-otp';

  // Billing
  static const String billingCheckout = 'billing/checkout';
  static const String billingPortal = 'billing/portal';
  static const String billingRevoke = 'billing/revoke';

  // Courses
  static const String courses = 'courses';
  static String courseById(int id) => 'courses/$id';
  static String enrollInCourse(int id) => 'courses/$id/enroll';
  static String unenrollFromCourse(int id) => 'courses/$id/enroll';
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
  static String deleteOrganizationDashboard(String slug) =>
      'organizations/$slug/leave';

  static String organizationCourses(String orgSlug) => 'organizations/$orgSlug/courses';

  static String courseBySlug({
    required String orgSlug,
    required String courseSlug,
  }) => 'organizations/$orgSlug/courses/$courseSlug';
  // Blocks
  static String blockContent(int blockId) => 'blocks/$blockId';
  static String submitBlockAnswer(int blockId) => 'blocks/$blockId/submit';

  // Gamification
  static const String gamificationMe = 'gamification/me';
  static const String gamificationStreak = 'gamification/streak';
  static const String gamificationActivity = 'gamification/activity';
  static const String gamificationScoreboard = 'gamification/scoreboard';
}
