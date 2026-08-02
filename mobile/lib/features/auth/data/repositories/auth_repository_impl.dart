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

    print("REPOSITORY START");

    if (await networkInfo.isConnected!) {

      print("INTERNET OK");

      try {

        print("CALLING REMOTE DATASOURCE");

        final remoteAuthData =
        await remoteDataSource.loginWithTelegram();

        print("REMOTE DATASOURCE FINISHED");

        print(remoteAuthData);

        print("CACHING DATA");

        await localDataSource.cacheAuthData(remoteAuthData);

        final auth =
        await localDataSource.getCachedAuthData();

        print("TOKEN = ${auth.token}");

        print("CACHE FINISHED");

        return Right(remoteAuthData);

      } on ServerException catch (e) {

        print("SERVER EXCEPTION");

        print(e);

        return Left(
          Failure(
            errMessage: e.errorModel.errorMessage,
          ),
        );

      } catch (e) {

        print("GENERAL EXCEPTION");

        print(e);

        return Left(
          Failure(
            errMessage: e.toString(),
          ),
        );
      }

    } else {

      print("NO INTERNET");

      return Left(
        Failure(
          errMessage:
          "No Internet Connection. Please check your network and try again.",
        ),
      );
    }
  }

  @override
  Future<Either<Failure, AuthEntity?>> checkCachedAuth() async {
    try {
      final cachedAuth = await localDataSource.getCachedAuthData();
      return Right(cachedAuth);
    } on CacheExeption {
      return const Right(null);
    } catch (e) {
      return Left(Failure(errMessage: "Failed to check cached authentication"));
    }
  }

  @override
  Future<void> logout() async {
    try {
      await localDataSource.cache.removeData(key: localDataSource.key);
    } catch (e) {
      throw CacheExeption(errorMessage: "Failed to clear cached authentication");
    }
  }
}