import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:data_connection_checker_tv/data_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/assessments/final_exam/data/datasources/final_exam_remote_datasource.dart';
import '../../features/assessments/final_exam/data/repositories/final_exam_repository_impl.dart';
import '../../features/assessments/final_exam/domain/repositories/final_exam_repository.dart';
import '../../features/assessments/final_exam/domain/usecases/get_final_exam_usecase.dart';
import '../../features/assessments/final_exam/domain/usecases/submit_final_exam_usecase.dart';
import '../../features/assessments/final_exam/presesntation/bloc/final_exam_bloc.dart';
import '../../features/assessments/practice_exam/data/datasources/practice_exam_remote_datasource.dart';
import '../../features/assessments/practice_exam/data/repositories/practice_exam_repository_impl.dart';
import '../../features/assessments/practice_exam/domain/repositories/practice_exam_repository.dart';
import '../../features/assessments/practice_exam/domain/usecases/get_practice_exam_details_usecase.dart';
import '../../features/assessments/practice_exam/domain/usecases/get_practice_exam_list_usecase.dart';
import '../../features/assessments/practice_exam/domain/usecases/submit_practice_exam_usecase.dart';
import '../../features/assessments/practice_exam/presentation/bloc/practice_exam_bloc.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../../features/courses/data/datasources/block_remote_datasource.dart';
import '../../features/courses/data/repositories/block_repository_impl.dart';
import '../../features/courses/domain/repositories/block_repository.dart';
import '../../features/courses/domain/usecases/enroll_in_course_usecase.dart';
import '../../features/courses/domain/usecases/get_all_courses_usecase.dart';
import '../../features/courses/domain/usecases/get_block_content_usecase.dart';
import '../../features/courses/domain/usecases/get_course_by_id_usecase.dart';
import '../../features/courses/domain/usecases/get_course_by_slug_usecase.dart';
import '../../features/courses/domain/usecases/submit_block_answer_usecase.dart';
import '../../features/courses/domain/usecases/unenroll_from_course_usecase.dart';
import '../../features/courses/presentation/bloc/block_content_bloc.dart';
import '../../features/home/bloc/home_bloc.dart';
import '../../features/organizations/domain/usecases/cancel_join_request_usecase.dart';
import '../../features/organizations/domain/usecases/accept_organization_invite_usecase.dart';
import '../../features/organizations/domain/usecases/accept_organization_invite_by_token_usecase.dart';
import '../../features/organizations/domain/usecases/delete_organization_usecase.dart';
import '../../features/organizations/domain/usecases/decline_organization_invite_usecase.dart';
import '../../features/organizations/domain/usecases/get_my_organization_invites_usecase.dart';
import '../../features/organizations/domain/usecases/get_my_organizations_usecase.dart';
import '../../features/organizations/domain/usecases/get_organization_invite_preview_by_token_usecase.dart';
import '../../features/organizations/domain/usecases/get_organization_courses_usecase.dart';
import '../../features/organizations/domain/usecases/join_organization_usecase.dart';
import '../../features/organizations/domain/usecases/leave_organization_usecase.dart';
import '../../features/organizations/presentation/bloc/organization_bloc.dart';
import '../../features/organizations/presentation/bloc/organization_courses_bloc.dart';
import '../../features/organizations/presentation/bloc/organization_details_bloc.dart';
import '../../features/organizations/presentation/bloc/public_organization_invite_bloc.dart';
import '../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_current_account_email_usecase.dart';
import '../../features/profile/domain/usecases/get_profile_usecase.dart';
import '../../features/profile/domain/usecases/request_account_email_otp_usecase.dart';
import '../../features/profile/domain/usecases/update_profile_picture_usecase.dart';
import '../../features/profile/domain/usecases/update_profile_usecase.dart';
import '../../features/profile/domain/usecases/verify_account_email_otp_usecase.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/recommendations/data/datasources/recommendation_remote_datasource.dart';
import '../../features/recommendations/data/repositories/recommendation_repository_impl.dart';
import '../../features/recommendations/domain/repositories/recommendation_repository.dart';
import '../../features/recommendations/domain/usecases/get_recommended_courses_usecase.dart';
import '../../features/recommendations/domain/usecases/get_recommended_organizations_usecase.dart';
import '../../features/roadmaps/domain/usecases/get_my_roadmaps_usecase.dart';
import '../connection/network_info.dart';
import '../databases/api/api_consumer.dart';
import '../databases/api/dio_consumer.dart';
import '../databases/cache/cache_helper.dart';

// Import Auth Feature
import 'package:lms/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:lms/features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_with_google.dart';
import '../../features/auth/domain/usecases/login_with_telegram.dart';
import '../../features/auth/domain/usecases/request_email_otp.dart';
import '../../features/auth/domain/usecases/verify_email_otp.dart';
import '../../features/auth/domain/usecases/check_cached_auth_usecase.dart'; // ADD THIS
import '../../features/auth/domain/usecases/logout_usecase.dart'; // ADD THIS
import '../../features/billing/data/datasources/billing_remote_datasource.dart';
import '../../features/billing/data/repositories/billing_repository_impl.dart';
import '../../features/billing/domain/repositories/billing_repository.dart';
import '../../features/billing/domain/usecases/create_checkout_session_usecase.dart';
import '../../features/billing/domain/usecases/create_portal_session_usecase.dart';
import '../../features/billing/domain/usecases/get_billing_user_usecase.dart';
import '../../features/billing/domain/usecases/revoke_subscription_usecase.dart';
import '../../features/billing/presentation/bloc/billing_bloc.dart';
//Courses Feature
import 'package:lms/features/courses/data/datasources/course_remote_datasource.dart';
import 'package:lms/features/courses/data/repositories/course_repository_impl.dart';
import 'package:lms/features/courses/domain/repositories/course_repository.dart';
import 'package:lms/features/courses/domain/usecases/get_my_enrollments_usecase.dart';
import 'package:lms/features/courses/presentation/bloc/my_courses_bloc.dart';
import 'package:lms/features/courses/presentation/bloc/course_details_bloc.dart';
import 'package:lms/features/courses/presentation/bloc/course_contents_bloc.dart';
import 'package:lms/features/courses/data/datasources/placement_test_remote_datasource.dart';
import 'package:lms/features/courses/data/repositories/placement_test_repository_impl.dart';
import 'package:lms/features/courses/domain/repositories/placement_test_repository.dart';
import 'package:lms/features/courses/domain/usecases/get_placement_test_usecase.dart';
import 'package:lms/features/courses/domain/usecases/submit_placement_answer_usecase.dart';
import 'package:lms/features/courses/domain/usecases/skip_placement_test_usecase.dart';
import 'package:lms/features/courses/presentation/bloc/placement_test_bloc.dart';
// Friends Feature
import 'package:lms/features/friends/data/datasources/friends_remote_datasource.dart';
import 'package:lms/features/friends/data/repositories/friends_repository_impl.dart';
import 'package:lms/features/friends/domain/repositories/friends_repository.dart';
import 'package:lms/features/friends/domain/usecases/accept_friend_request_usecase.dart';
import 'package:lms/features/friends/domain/usecases/cancel_friend_request_usecase.dart';
import 'package:lms/features/friends/domain/usecases/get_friends_usecase.dart';
import 'package:lms/features/friends/domain/usecases/get_received_friend_requests_usecase.dart';
import 'package:lms/features/friends/domain/usecases/get_sent_friend_requests_usecase.dart';
import 'package:lms/features/friends/domain/usecases/get_user_profile_usecase.dart';
import 'package:lms/features/friends/domain/usecases/reject_friend_request_usecase.dart';
import 'package:lms/features/friends/domain/usecases/remove_friend_usecase.dart';
import 'package:lms/features/friends/domain/usecases/search_users_usecase.dart';
import 'package:lms/features/friends/domain/usecases/send_friend_request_usecase.dart';
import 'package:lms/features/friends/presentation/bloc/add_friend_bloc.dart';
import 'package:lms/features/friends/presentation/bloc/friends_bloc.dart';
import 'package:lms/features/friends/presentation/bloc/user_profile_bloc.dart';
// Chat Feature
import 'package:lms/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:lms/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:lms/features/chat/domain/repositories/chat_repository.dart';
import 'package:lms/features/chat/domain/usecases/create_direct_conversation_usecase.dart';
import 'package:lms/features/chat/domain/usecases/get_conversations_usecase.dart';
import 'package:lms/features/chat/domain/usecases/get_messages_usecase.dart';
import 'package:lms/features/chat/domain/usecases/mark_conversation_as_read_usecase.dart';
import 'package:lms/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:lms/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:lms/features/chat/presentation/bloc/chat_messages_bloc.dart';
import 'package:lms/features/chat/presentation/bloc/new_chat_bloc.dart';
//Organization Feature
import 'package:lms/features/organizations/data/datasources/organization_remote_datasource.dart';
import 'package:lms/features/organizations/data/repositories/organization_repository_impl.dart';
import 'package:lms/features/organizations/domain/repositories/organization_repository.dart';
import 'package:lms/features/organizations/domain/usecases/get_all_organizations_usecase.dart';
import 'package:lms/features/organizations/domain/usecases/get_organization_by_slug_usecase.dart';

// Gamification
import '../../features/gamification/data/datasources/gamification_remote_datasource.dart';
import '../../features/gamification/data/repositories/gamification_repository_impl.dart';
import '../../features/gamification/domain/repositories/gamification_repository.dart';
import '../../features/gamification/domain/usecases/get_my_progress_usecase.dart';
import '../../features/gamification/domain/usecases/get_my_streak_usecase.dart';
import '../../features/gamification/domain/usecases/get_activity_usecase.dart';
import '../../features/gamification/domain/usecases/get_leaderboard_usecase.dart';
import '../../features/gamification/presentation/bloc/gamification_bloc.dart';

import 'chat_updates_notifier.dart';
import 'external_url_launcher.dart';
import 'foreground_notification_service.dart';
import 'firebase_messaging_service.dart';
import 'pusher_chat_service.dart';
import '../theme/theme_cubit.dart';

// Notifications
import '../../features/notifications/data/datasources/notification_remote_datasource.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/notifications/domain/usecases/deactivate_notification_device_usecase.dart';
import '../../features/notifications/domain/usecases/get_notifications_usecase.dart';
import '../../features/notifications/domain/usecases/get_unread_notification_count_usecase.dart';
import '../../features/notifications/domain/usecases/mark_all_notifications_read_usecase.dart';
import '../../features/notifications/domain/usecases/mark_notification_read_usecase.dart';
import '../../features/notifications/domain/usecases/register_notification_device_usecase.dart';
import '../../features/notifications/presentation/bloc/notifications_bloc.dart';

// Posts
import '../../features/posts/data/datasources/posts_remote_datasource.dart';
import '../../features/posts/data/repositories/posts_repository_impl.dart';
import '../../features/posts/domain/repositories/posts_repository.dart';
import '../../features/posts/domain/usecases/get_organization_posts_usecase.dart';
import '../../features/posts/domain/usecases/get_course_posts_usecase.dart';
import '../../features/posts/domain/usecases/get_comments_usecase.dart';
import '../../features/posts/domain/usecases/add_comment_usecase.dart';
import '../../features/posts/domain/usecases/delete_comment_usecase.dart';
import '../../features/posts/domain/usecases/like_comment_usecase.dart';
import '../../features/posts/domain/usecases/unlike_comment_usecase.dart';
import '../../features/posts/domain/usecases/react_to_post_usecase.dart';
import '../../features/posts/presentation/bloc/posts_bloc.dart';
import '../../features/posts/presentation/bloc/post_details_bloc.dart';

// Roadmaps
import '../../features/roadmaps/data/datasources/roadmap_remote_datasource.dart';
import '../../features/roadmaps/data/repositories/roadmap_repository_impl.dart';
import '../../features/roadmaps/domain/repositories/roadmap_repository.dart';
import '../../features/roadmaps/domain/usecases/get_organization_roadmaps_usecase.dart';
import '../../features/roadmaps/domain/usecases/get_roadmap_details_usecase.dart';
import '../../features/roadmaps/domain/usecases/follow_roadmap_usecase.dart';
import '../../features/roadmaps/domain/usecases/unfollow_roadmap_usecase.dart';
import '../../features/roadmaps/presentation/bloc/roadmap_bloc.dart';

// AI Quiz
import '../../features/assessments/ai_quiz/data/datasources/ai_quiz_remote_datasource.dart';
import '../../features/assessments/ai_quiz/data/repositories/ai_quiz_repository_impl.dart';
import '../../features/assessments/ai_quiz/domain/repositories/ai_quiz_repository.dart';
import '../../features/assessments/ai_quiz/domain/usecases/generate_ai_quiz_usecase.dart';
import '../../features/assessments/ai_quiz/domain/usecases/submit_ai_quiz_usecase.dart';
import '../../features/assessments/ai_quiz/presentation/bloc/ai_quiz_bloc.dart';

// Random Quiz
import '../../features/assessments/random_quiz/data/datasources/random_quiz_remote_datasource.dart';
import '../../features/assessments/random_quiz/data/repositories/random_quiz_repository_impl.dart';
import '../../features/assessments/random_quiz/domain/repositories/random_quiz_repository.dart';
import '../../features/assessments/random_quiz/domain/usecases/generate_random_quiz_usecase.dart';
import '../../features/assessments/random_quiz/domain/usecases/submit_random_quiz_usecase.dart';
import '../../features/assessments/random_quiz/presentation/bloc/random_quiz_bloc.dart';

// Practice Quiz
import '../../features/assessments/practice_quiz/data/datasources/practice_quiz_remote_datasource.dart';
import '../../features/assessments/practice_quiz/data/repositories/practice_quiz_repository_impl.dart';
import '../../features/assessments/practice_quiz/domain/repositories/practice_quiz_repository.dart';
import '../../features/assessments/practice_quiz/domain/usecases/get_practice_quiz_list_usecase.dart';
import '../../features/assessments/practice_quiz/domain/usecases/get_practice_quiz_details_usecase.dart';
import '../../features/assessments/practice_quiz/domain/usecases/submit_practice_quiz_usecase.dart';
import '../../features/assessments/practice_quiz/presentation/bloc/practice_quiz_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Auth

  // Use cases
  sl.registerLazySingleton(() => LoginWithTelegram(repository: sl()));
  sl.registerLazySingleton(() => LoginWithGoogle(repository: sl()));
  sl.registerLazySingleton(() => RequestEmailOtp(repository: sl()));
  sl.registerLazySingleton(() => VerifyEmailOtp(repository: sl()));
  sl.registerLazySingleton(() => CheckCachedAuth(repository: sl()));
  sl.registerLazySingleton(() => Logout(repository: sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton(
    () => AuthBloc(
      loginWithTelegram: sl(),
      loginWithGoogle: sl(),
      requestEmailOtp: sl(),
      verifyEmailOtp: sl(),
      checkCachedAuth: sl(),
      logout: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      appAuth: sl(),
      googleSignIn: sl(),
      apiConsumer: sl(),
    ),
  );
  sl.registerLazySingleton(() => AuthLocalDataSource(cache: sl()));

  // Billing
  sl.registerLazySingleton<BillingRemoteDataSource>(
    () => BillingRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<BillingRepository>(
    () => BillingRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetBillingUserUseCase(sl()));
  sl.registerLazySingleton(() => CreateCheckoutSessionUseCase(sl()));
  sl.registerLazySingleton(() => CreatePortalSessionUseCase(sl()));
  sl.registerLazySingleton(() => RevokeSubscriptionUseCase(sl()));
  sl.registerFactory(
    () => BillingBloc(
      getBillingUserUseCase: sl(),
      createCheckoutSessionUseCase: sl(),
      createPortalSessionUseCase: sl(),
      revokeSubscriptionUseCase: sl(),
    ),
  );

  //! Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  sl.registerLazySingleton<ApiConsumer>(() {
    final consumer = DioConsumer(dio: sl(), authLocalDataSource: sl());
    consumer.onTokenInvalid = () {
      sl<AuthBloc>().add(LogoutRequested());
    };
    return consumer;
  });

  sl.registerLazySingleton(
    () => Dio(
      BaseOptions(
        baseUrl: 'http://10.0.2.2:8080/',
        receiveDataWhenStatusError: true,
      ),
    ),
  );

  // Profile
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl()),
  );

  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentAccountEmailUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfilePictureUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => RequestAccountEmailOtpUseCase(sl()));
  sl.registerLazySingleton(() => VerifyAccountEmailOtpUseCase(sl()));

  sl.registerFactory(
    () => ProfileBloc(
      getProfileUseCase: sl(),
      getCurrentAccountEmailUseCase: sl(),
      updatePictureUseCase: sl(),
      updateProfileUseCase: sl(),
      requestAccountEmailOtpUseCase: sl(),
      verifyAccountEmailOtpUseCase: sl(),
    ),
  );

  // Courses
  sl.registerLazySingleton<CourseRemoteDataSource>(
    () => CourseRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<CourseRepository>(() => CourseRepositoryImpl(sl()));

  sl.registerLazySingleton(() => GetAllCoursesUseCase(sl()));
  sl.registerLazySingleton(() => GetMyEnrollmentsUseCase(sl()));
  sl.registerLazySingleton(() => GetCourseByIdUseCase(sl()));
  sl.registerLazySingleton(() => GetCourseBySlugUseCase(sl()));
  sl.registerLazySingleton(() => EnrollInCourseUseCase(sl()));
  sl.registerLazySingleton(() => UnenrollFromCourseUseCase(sl()));
  sl.registerFactory(() => MyCoursesBloc(getMyEnrollmentsUseCase: sl()));

  sl.registerFactory(
    () => CourseDetailsBloc(
      getCourseByIdUseCase: sl(),
      getCourseBySlugUseCase: sl(),
      enrollInCourseUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => CourseContentsBloc(
      getCourseByIdUseCase: sl(),
      unenrollFromCourseUseCase: sl(),
    ),
  );

  sl.registerLazySingleton<PlacementTestRemoteDataSource>(
    () => PlacementTestRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<PlacementTestRepository>(
    () => PlacementTestRepositoryImpl(sl()),
  );

  sl.registerLazySingleton(() => GetPlacementTestUseCase(sl()));
  sl.registerLazySingleton(() => SubmitPlacementAnswerUseCase(sl()));
  sl.registerLazySingleton(() => SkipPlacementTestUseCase(sl()));

  sl.registerFactory(
    () => PlacementTestBloc(
      getPlacementTestUseCase: sl(),
      submitPlacementAnswerUseCase: sl(),
      skipPlacementTestUseCase: sl(),
    ),
  );

  // Organizations
  sl.registerLazySingleton<OrganizationRemoteDataSource>(
    () => OrganizationRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<OrganizationRepository>(
    () => OrganizationRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => DeleteOrganizationUseCase(sl()));
  sl.registerLazySingleton(() => GetAllOrganizationsUseCase(sl()));
  sl.registerLazySingleton(() => GetOrganizationBySlugUseCase(sl()));
  sl.registerLazySingleton(() => JoinOrganizationUseCase(sl()));
  sl.registerLazySingleton(() => LeaveOrganizationUseCase(sl()));
  sl.registerLazySingleton(() => CancelJoinRequestUseCase(sl()));
  sl.registerLazySingleton(() => GetMyOrganizationInvitesUseCase(sl()));
  sl.registerLazySingleton(() => AcceptOrganizationInviteUseCase(sl()));
  sl.registerLazySingleton(() => AcceptOrganizationInviteByTokenUseCase(sl()));
  sl.registerLazySingleton(
    () => GetOrganizationInvitePreviewByTokenUseCase(sl()),
  );
  sl.registerLazySingleton(() => DeclineOrganizationInviteUseCase(sl()));
  sl.registerLazySingleton(() => GetOrganizationCoursesUseCase(sl()));
  sl.registerLazySingleton(() => GetMyOrganizationsUseCase(sl()));
  sl.registerFactory(
    () => OrganizationBloc(
      getAllOrganizationsUseCase: sl(),
      getMyOrganizationsUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => OrganizationDetailsBloc(
      getOrganizationBySlugUseCase: sl(),
      joinOrganizationUseCase: sl(),
      leaveOrganizationUseCase: sl(),
      cancelJoinRequestUseCase: sl(),
      acceptOrganizationInviteUseCase: sl(),
      deleteOrganizationUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => OrganizationCoursesBloc(getOrganizationCoursesUseCase: sl()),
  );
  sl.registerFactory(
    () => PublicOrganizationInviteBloc(
      acceptInviteByTokenUseCase: sl(),
      getInvitePreviewByTokenUseCase: sl(),
    ),
  );

  // Recommendations
  sl.registerLazySingleton<RecommendationRemoteDataSource>(
    () => RecommendationRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<RecommendationRepository>(
    () => RecommendationRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetRecommendedCoursesUseCase(sl()));
  sl.registerLazySingleton(() => GetRecommendedOrganizationsUseCase(sl()));

  // Notifications
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetNotificationsUseCase(sl()));
  sl.registerLazySingleton(() => GetUnreadNotificationCountUseCase(sl()));
  sl.registerLazySingleton(() => MarkNotificationReadUseCase(sl()));
  sl.registerLazySingleton(() => MarkAllNotificationsReadUseCase(sl()));
  sl.registerLazySingleton(() => RegisterNotificationDeviceUseCase(sl()));
  sl.registerLazySingleton(() => DeactivateNotificationDeviceUseCase(sl()));
  sl.registerFactory(
    () => NotificationsBloc(
      getMyOrganizationInvitesUseCase: sl(),
      acceptOrganizationInviteUseCase: sl(),
      declineOrganizationInviteUseCase: sl(),
      getNotificationsUseCase: sl(),
      getUnreadNotificationCountUseCase: sl(),
      markNotificationReadUseCase: sl(),
      markAllNotificationsReadUseCase: sl(),
    ),
  );
  sl.registerLazySingleton(() => ForegroundNotificationService());
  sl.registerLazySingleton(
    () => FirebaseMessagingService(
      registerDevice: sl(),
      foregroundNotificationService: sl(),
    ),
  );

  // Blocks
  sl.registerLazySingleton<BlockRemoteDataSource>(
    () => BlockRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<BlockRepository>(() => BlockRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetBlockContentUseCase(sl()));
  sl.registerLazySingleton(() => SubmitBlockAnswerUseCase(sl()));
  sl.registerFactory(
    () => BlockContentBloc(
      getBlockContentUseCase: sl(),
      submitBlockAnswerUseCase: sl(),
    ),
  );

  // Gamification
  sl.registerLazySingleton<GamificationRemoteDataSource>(
    () => GamificationRemoteDataSourceImpl(api: sl()),
  );
  sl.registerLazySingleton<GamificationRepository>(
    () => GamificationRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetMyProgressUseCase(sl()));
  sl.registerLazySingleton(() => GetMyStreakUseCase(sl()));
  sl.registerLazySingleton(() => GetActivityUseCase(sl()));
  sl.registerLazySingleton(() => GetLeaderboardUseCase(sl()));
  sl.registerFactory(
    () => GamificationBloc(
      getMyProgress: sl(),
      getMyStreak: sl(),
      getActivity: sl(),
      getLeaderboard: sl(),
    ),
  );

  // Posts
  sl.registerLazySingleton<PostsRemoteDataSource>(
    () => PostsRemoteDataSourceImpl(api: sl()),
  );
  sl.registerLazySingleton<PostsRepository>(
    () => PostsRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetOrganizationPostsUseCase(sl()));
  sl.registerLazySingleton(() => GetCoursePostsUseCase(sl()));
  sl.registerLazySingleton(() => GetCommentsUseCase(sl()));
  sl.registerLazySingleton(() => AddCommentUseCase(sl()));
  sl.registerLazySingleton(() => DeleteCommentUseCase(sl()));
  sl.registerLazySingleton(() => LikeCommentUseCase(sl()));
  sl.registerLazySingleton(() => UnlikeCommentUseCase(sl()));
  sl.registerLazySingleton(() => ReactToPostUseCase(sl()));
  sl.registerFactory(
    () => PostsBloc(getOrganizationPosts: sl(), getCoursePosts: sl()),
  );
  sl.registerFactory(
    () => PostDetailsBloc(
      getComments: sl(),
      addComment: sl(),
      deleteComment: sl(),
      likeComment: sl(),
      unlikeComment: sl(),
      reactToPost: sl(),
    ),
  );

  //Roadmaps
  sl.registerLazySingleton<RoadmapRemoteDataSource>(
    () => RoadmapRemoteDataSourceImpl(api: sl()),
  );
  sl.registerLazySingleton<RoadmapRepository>(
    () => RoadmapRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetOrganizationRoadmapsUseCase(sl()));
  sl.registerLazySingleton(() => GetRoadmapDetailsUseCase(sl()));
  sl.registerLazySingleton(() => FollowRoadmapUseCase(sl()));
  sl.registerLazySingleton(() => UnfollowRoadmapUseCase(sl()));
  sl.registerLazySingleton(() => GetMyRoadmapsUseCase(sl()));

  sl.registerFactory(() => RoadmapBloc(
    getOrganizationRoadmaps: sl(),
    getRoadmapDetails: sl(),
    followRoadmap: sl(),
    unfollowRoadmap: sl(),
    getMyRoadmaps: sl(),
  ));

  //Ai Quiz
  sl.registerLazySingleton<AiQuizRemoteDataSource>(
    () => AiQuizRemoteDataSourceImpl(api: sl()),
  );
  sl.registerLazySingleton<AiQuizRepository>(
    () => AiQuizRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => GenerateAiQuizUseCase(sl()));
  sl.registerLazySingleton(() => SubmitAiQuizUseCase(sl()));
  sl.registerFactory(
    () => AiQuizBloc(generateAiQuiz: sl(), submitAiQuiz: sl()),
  );

  //Random Quiz
  sl.registerLazySingleton<RandomQuizRemoteDataSource>(
    () => RandomQuizRemoteDataSourceImpl(api: sl()),
  );
  sl.registerLazySingleton<RandomQuizRepository>(
    () => RandomQuizRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => GenerateRandomQuizUseCase(sl()));
  sl.registerLazySingleton(() => SubmitRandomQuizUseCase(sl()));
  sl.registerFactory(
    () => RandomQuizBloc(generateRandomQuiz: sl(), submitRandomQuiz: sl()),
  );

  // Practice Quiz
  sl.registerLazySingleton<PracticeQuizRemoteDataSource>(
    () => PracticeQuizRemoteDataSourceImpl(api: sl()),
  );
  sl.registerLazySingleton<PracticeQuizRepository>(
    () => PracticeQuizRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetPracticeQuizListUseCase(sl()));
  sl.registerLazySingleton(() => GetPracticeQuizDetailsUseCase(sl()));
  sl.registerLazySingleton(() => SubmitPracticeQuizUseCase(sl()));
  sl.registerFactory(() => PracticeQuizBloc(
    getList: sl(),
    getDetails: sl(),
    submit: sl(),
  ));

  // Practice Exam
  sl.registerLazySingleton<PracticeExamRemoteDataSource>(
    () => PracticeExamRemoteDataSourceImpl(api: sl()),
  );
  sl.registerLazySingleton<PracticeExamRepository>(
    () => PracticeExamRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetPracticeExamListUseCase(sl()));
  sl.registerLazySingleton(() => GetPracticeExamDetailsUseCase(sl()));
  sl.registerLazySingleton(() => SubmitPracticeExamUseCase(sl()));
  sl.registerFactory(() => PracticeExamBloc(
    getList: sl(),
    getDetails: sl(),
    submit: sl(),
  ));

  // Final Exam
  sl.registerLazySingleton<FinalExamRemoteDataSource>(
    () => FinalExamRemoteDataSourceImpl(api: sl()),
  );
  sl.registerLazySingleton<FinalExamRepository>(
    () => FinalExamRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetFinalExamUseCase(sl()));
  sl.registerLazySingleton(() => SubmitFinalExamUseCase(sl()));
  sl.registerFactory(() => FinalExamBloc(getExam: sl(), submit: sl()));

  // Home
  sl.registerFactory(
    () => HomeBloc(
      getRecommendedCoursesUseCase: sl(),
      getRecommendedOrganizationsUseCase: sl(),
    ),
  );

  //! External

  // SharedPreferences initialization
  final sharedPreferences = await SharedPreferences.getInstance();
  final cacheHelper = CacheHelper();
  await cacheHelper.init();

  sl.registerLazySingleton<CacheHelper>(() => cacheHelper);
  sl.registerLazySingleton(() => sharedPreferences);

  sl.registerSingleton(ThemeCubit()..setTheme(sl<CacheHelper>().getTheme()));

  sl.registerLazySingleton(() => const FlutterAppAuth());
  sl.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn.instance);
  sl.registerLazySingleton(() => DataConnectionChecker());
  sl.registerLazySingleton(() => ExternalUrlLauncher());
}
