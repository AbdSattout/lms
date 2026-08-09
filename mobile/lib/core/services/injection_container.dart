import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:data_connection_checker_tv/data_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
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

import 'external_url_launcher.dart';
import 'firebase_messaging_service.dart';
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

  sl.registerFactory(
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

  sl.registerLazySingleton<ApiConsumer>(
    () => DioConsumer(dio: sl(), authLocalDataSource: sl()),
  );

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
  sl.registerLazySingleton(() => DeclineOrganizationInviteUseCase(sl()));
  sl.registerLazySingleton(() => GetOrganizationCoursesUseCase(sl()));
  sl.registerFactory(() => OrganizationBloc(getAllOrganizationsUseCase: sl()));

  sl.registerFactory(
    () => OrganizationDetailsBloc(
      getOrganizationBySlugUseCase: sl(),
      joinOrganizationUseCase: sl(),
      leaveOrganizationUseCase: sl(),
      cancelJoinRequestUseCase: sl(),
      deleteOrganizationUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => OrganizationCoursesBloc(getOrganizationCoursesUseCase: sl()),
  );
  sl.registerFactory(
    () => PublicOrganizationInviteBloc(acceptInviteByTokenUseCase: sl()),
  );

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
  sl.registerLazySingleton(
    () => FirebaseMessagingService(registerDevice: sl()),
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

  // Home
  sl.registerFactory(
    () =>
        HomeBloc(getAllCoursesUseCase: sl(), getAllOrganizationsUseCase: sl()),
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
