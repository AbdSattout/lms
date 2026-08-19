class EndPoints {
  // Base API URL for the backend
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://masarapi.up.railway.app/',
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

  // Notifications
  static const String notifications = 'notifications';
  static const String notificationUnreadCount = 'notifications/unread-count';
  static String notificationRead(int id) => 'notifications/$id/read';
  static const String notificationsReadAll = 'notifications/read-all';
  static const String devices = 'devices';

  static const String profile = 'profile/me';

  static const String currentUser = 'users/me';

  static const String updateProfilePicture = 'users/me/picture';

  static const String reports = 'reports';

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
  static const String myOrganizations = 'organizations/me';
  static String organizationBySlug(String slug) => 'organizations/$slug';
  static String organizationJoin(String slug) => 'organizations/$slug/join';
  static String organizationLeave(String slug) => 'organizations/$slug/leave';
  static String deleteOrganizationDashboard(String slug) =>
      'organizations/$slug/leave';
  static const String organizationMyInvites =
      'organizations/invites/my-invites';
  static const String organizationInvitePreviewByToken =
      'organizations/invites/preview';
  static const String organizationInviteAcceptByToken =
      'organizations/invites/accept';
  static String organizationInviteAccept(String slug, int inviteId) =>
      'organizations/$slug/invites/$inviteId/accept';
  static String organizationInviteDecline(String slug, int inviteId) =>
      'organizations/$slug/invites/$inviteId/decline';

  static String organizationCourses(String orgSlug) =>
      'organizations/$orgSlug/courses';

  // Recommendations
  static const String recommendedCourses = 'recommendations/courses';
  static const String recommendedOrganizations =
      'recommendations/organizations';

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

  // Posts
  static String organizationPosts(String orgSlug) =>
      'organizations/$orgSlug/posts';
  static String coursePosts(int courseId) => 'courses/$courseId/posts';
  static String postComments(int postId) => 'posts/$postId/comments';
  static String deleteComment(int commentId) => 'comments/$commentId';
  static String commentLikes(int commentId) => 'comments/$commentId/likes';
  static String postLikes(int postId) => 'posts/$postId/likes';

  // Media
  static String courseMedia(String orgId, String courseId, String mediaId) =>
      'mobile/organizations/$orgId/courses/$courseId/media/$mediaId';

  static String postMedia(String orgId, String mediaId) =>
      'mobile/organizations/$orgId/post-media/$mediaId';

  // Roadmaps
  static const String allRoadmaps = 'mobile/roadmaps';
  static String organizationRoadmaps(String slug) =>
      'mobile/organizations/$slug/roadmaps';
  static String roadmapDetails(String slug, int roadmapId) =>
      'mobile/organizations/$slug/roadmaps/$roadmapId';
  static String followRoadmap(String slug, int roadmapId) =>
      'mobile/organizations/$slug/roadmaps/$roadmapId/follow';
  static const String myRoadmaps = 'mobile/roadmaps/following';

  // AI Quiz
  static String generateAiQuiz(int courseId) =>
      'mobile/ai/courses/$courseId/random-quiz';
  static String submitAiQuiz(int courseId, int attemptId) =>
      'mobile/ai/courses/$courseId/random-quiz/attempts/$attemptId/submit';

  // Random Quiz
  static String generateRandomQuiz(int courseId) =>
      'mobile/courses/$courseId/random-quiz';
  static String submitRandomQuiz(int courseId, int attemptId) =>
      'mobile/courses/$courseId/random-quiz/attempts/$attemptId/submit';

  // Practice Quiz
  static String practiceQuizList(int courseId) =>
      'mobile/courses/$courseId/practice-quizzes';
  static String practiceQuizDetails(int courseId, int quizId) =>
      'mobile/courses/$courseId/practice-quizzes/$quizId';
  static String submitPracticeQuiz(int courseId, int quizId) =>
      'mobile/courses/$courseId/practice-quizzes/$quizId/submit';

  // Practice Exam
  static String practiceExamList(int courseId) =>
      'mobile/courses/$courseId/practice-exams';
  static String practiceExamDetails(int courseId, int examId) =>
      'mobile/courses/$courseId/practice-exams/$examId';
  static String submitPracticeExam(int courseId, int examId) =>
      'mobile/courses/$courseId/practice-exams/$examId/submit';

  // Final Exam
  static String finalExam(int courseId) => 'mobile/courses/$courseId/quiz';
  static String submitFinalExam(int courseId) =>
      'mobile/courses/$courseId/quiz/submit';

  // Friends
  static const String friends = 'friends';
  static const String receivedFriendRequests = 'friends/requests/received';
  static const String sentFriendRequests = 'friends/requests/sent';
  static String sendFriendRequest(int userId) => 'friends/requests/$userId';
  static String acceptFriendRequest(int requestId) =>
      'friends/requests/$requestId/accept';
  static String rejectFriendRequest(int requestId) =>
      'friends/requests/$requestId/reject';
  static String cancelFriendRequest(int requestId) =>
      'friends/requests/$requestId';
  static String removeFriend(int friendId) => 'friends/$friendId';
  static String userProfile(int userId) => 'users/$userId/profile';
  static const String usersSearch = 'users/search';

  // Chat
  static const String chatConversations = 'chat/conversations';
  static String chatCreateDirectConversation(int targetUserId) =>
      'chat/conversations/direct/$targetUserId';
  static String chatCourseConversation(int courseId) =>
      'chat/conversations/courses/$courseId';
  static String chatConversationMessages(int conversationId) =>
      'chat/conversations/$conversationId/messages';
  static String chatEditMessage(int conversationId, int messageId) =>
      'chat/conversations/$conversationId/messages/$messageId';
  static String chatDeleteMessage(int conversationId, int messageId) =>
      'chat/conversations/$conversationId/messages/$messageId';
  static String chatMarkMessageRead(int conversationId, int messageId) =>
      'chat/conversations/$conversationId/messages/$messageId/read';
  static const String chatPusherAuth = 'chat/pusher/auth';

  // Search
  static String searchCourses(String query, {int page = 0, int size = 10}) =>
      'courses?q=$query&page=$page&size=$size';
  static String searchOrganizations(String query, {int page = 0, int size = 10}) =>
      'organizations?q=$query&page=$page&size=$size';
}
