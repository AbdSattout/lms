import 'package:dartz/dartz.dart';

import 'package:lms/core/connection/network_info.dart';
import 'package:lms/core/errors/exceptions.dart';
import 'package:lms/core/errors/failure.dart';
import 'package:lms/features/auth/domain/entities/auth_entity.dart';
import 'package:lms/features/auth/domain/repositories/auth_repository.dart';
import 'package:lms/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:lms/features/auth/data/datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl extends AuthRepository {
  final NetworkInfo networkInfo;
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, AuthEntity>> loginWithTelegram() async {
    // 1. Internet connection
    if (await networkInfo.isConnected) {
      try {
        // 2. trying login by external server (telegram server)
        final remoteAuthData = await remoteDataSource.loginWithTelegram();

        // 3. Success: saved token in local cache
        await localDataSource.cacheAuthData(remoteAuthData);

        // 4. Return data
        return Right(remoteAuthData);
      } on ServerException catch (e) {
        // Catch server errors (login errors)
        return Left(Failure(errMessage: e.errorModel.errorMessage));
      } on CacheException catch (e) {
        return Left(Failure(errMessage: e.errorMessage));
      }
    } else {
      // Login needs internet
      // We do not return cache data here, but rather give the user an error to allow internet access
      return Left(
        Failure(
          errMessage:
              "No Internet Connection. Please check your network and try again.",
        ),
      );
    }
  }
}
