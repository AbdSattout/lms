import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:data_connection_checker_tv/data_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import Core
import '../../features/auth/presentation/bloc/auth_bloc.dart';
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

// This is the service locator instance
final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Auth
  
  // Use cases
  sl.registerLazySingleton(() => LoginWithTelegram(repository: sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  
  sl.registerFactory(
    () => AuthBloc(sl()),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(appAuth: sl(), apiConsumer: sl()),
  );
  sl.registerLazySingleton(() => AuthLocalDataSource(cache: sl()));

  //! Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  

  sl.registerLazySingleton<ApiConsumer>(() => DioConsumer(dio: sl()));
  
  
  sl.registerLazySingleton(() => Dio(
    BaseOptions(
      // (Emulator):10.0.2.2  
      baseUrl: 'http://10.0.2.2:8080/',
      receiveDataWhenStatusError: true,
    ),
  ));
  
  sl.registerLazySingleton(() => CacheHelper());

  //! External
  
  // SharedPreferences initialization
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  
  sl.registerLazySingleton(() => const FlutterAppAuth());
  sl.registerLazySingleton(() => DataConnectionChecker());
}