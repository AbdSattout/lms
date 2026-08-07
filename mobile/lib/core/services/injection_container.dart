import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
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
import '../../features/courses/presentation/bloc/block_content_bloc.dart';
import '../../features/home/bloc/home_bloc.dart';
import '../../features/organizations/domain/usecases/cancel_join_request_usecase.dart';
import '../../features/organizations/domain/usecases/delete_organization_usecase.dart';
import '../../features/organizations/domain/usecases/join_organization_usecase.dart';
import '../../features/organizations/domain/usecases/leave_organization_usecase.dart';
import '../../features/organizations/presentation/bloc/organization_bloc.dart';
import '../../features/organizations/presentation/bloc/organization_details_bloc.dart';
import '../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_profile_usecase.dart';
import '../../features/profile/domain/usecases/update_profile_picture_usecase.dart';
import '../../features/profile/domain/usecases/update_profile_usecase.dart';
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
import '../../features/auth/domain/usecases/login_with_telegram.dart';
import '../../features/auth/domain/usecases/check_cached_auth_usecase.dart'; // ADD THIS
import '../../features/auth/domain/usecases/logout_usecase.dart'; // ADD THIS
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

import '../theme/theme_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Auth

  // Use cases
  sl.registerLazySingleton(() => LoginWithTelegram(repository: sl()));
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
      checkCachedAuth: sl(),
      logout: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSourceImpl(appAuth: sl(), apiConsumer: sl()),
  );
  sl.registerLazySingleton(() => AuthLocalDataSource(cache: sl()));

  //! Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  sl.registerLazySingleton<ApiConsumer>(
        () => DioConsumer(
      dio: sl(),
      authLocalDataSource: sl(),
    ),
  );

  sl.registerLazySingleton(() => Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:8080/',
      receiveDataWhenStatusError: true,
    ),
  ));

  // Profile
  sl.registerLazySingleton<ProfileRemoteDataSource>(
        () => ProfileRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<ProfileRepository>(
        () => ProfileRepositoryImpl(sl()),
  );

  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfilePictureUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));

  sl.registerFactory(
        () => ProfileBloc(
      getProfileUseCase: sl(),
      updatePictureUseCase: sl(),
      updateProfileUseCase: sl(),
    ),
  );

  // Courses
  sl.registerLazySingleton<CourseRemoteDataSource>(
        () => CourseRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<CourseRepository>(
        () => CourseRepositoryImpl(sl()),
  );

  sl.registerLazySingleton(() => GetAllCoursesUseCase(sl()));
  sl.registerLazySingleton(() => GetMyEnrollmentsUseCase(sl()));
  sl.registerLazySingleton(() => GetCourseByIdUseCase(sl()));
  sl.registerLazySingleton(() => GetCourseBySlugUseCase(sl()));
  sl.registerLazySingleton(() => EnrollInCourseUseCase(sl()));

  sl.registerFactory(
        () => MyCoursesBloc(getMyEnrollmentsUseCase: sl()),
  );

  sl.registerFactory(
        () => CourseDetailsBloc(
      getCourseByIdUseCase: sl(),
      getCourseBySlugUseCase: sl(),
      enrollInCourseUseCase: sl(),
    ),
  );

  sl.registerFactory(
        () => CourseContentsBloc(getCourseByIdUseCase: sl()),
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
  sl.registerFactory(
        () => OrganizationBloc(
      getAllOrganizationsUseCase: sl(),
    ),
  );
  sl.registerFactory(
        () => OrganizationDetailsBloc(
      getOrganizationBySlugUseCase: sl(),
      joinOrganizationUseCase: sl(),
      leaveOrganizationUseCase: sl(),
      cancelJoinRequestUseCase: sl(),
      deleteOrganizationUseCase: sl(),
    ),
  );
  // Blocks
  sl.registerLazySingleton<BlockRemoteDataSource>(() => BlockRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<BlockRepository>(() => BlockRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetBlockContentUseCase(sl()));
  sl.registerLazySingleton(() => SubmitBlockAnswerUseCase(sl()));
  sl.registerFactory(() => BlockContentBloc(
    getBlockContentUseCase: sl(),
    submitBlockAnswerUseCase: sl(),
  ));

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
        () => HomeBloc(
      getAllCoursesUseCase: sl(),
      getAllOrganizationsUseCase: sl(),
    ),
  );

  //! External

  // SharedPreferences initialization
  final sharedPreferences = await SharedPreferences.getInstance();
  final cacheHelper = CacheHelper();
  await cacheHelper.init();

  sl.registerLazySingleton<CacheHelper>(() => cacheHelper);
  sl.registerLazySingleton(() => sharedPreferences);

  sl.registerSingleton(
    ThemeCubit()..setTheme(sl<CacheHelper>().getTheme()),
  );

  sl.registerLazySingleton(() => const FlutterAppAuth());
  sl.registerLazySingleton(() => DataConnectionChecker());
}