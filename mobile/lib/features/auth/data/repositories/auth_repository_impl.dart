import 'package:dartz/dartz.dart';

import 'package:lms/core/connection/network_info.dart';
import 'package:lms/core/errors/exceptions.dart';
import 'package:lms/core/errors/failure.dart';
import 'package:lms/features/auth/domain/entities/auth_entity.dart';
import 'package:lms/features/auth/domain/repositories/auth_repository.dart';
import 'package:lms/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:lms/features/auth/data/datasources/auth_remote_datasource.dart';
import '../models/auth_model.dart';

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
    if (await networkInfo.isConnected!) {
      try {
        final remoteAuthData = await remoteDataSource.loginWithTelegram();
        await _cacheAuthData(remoteAuthData);
        return Right(remoteAuthData);
      } on ServerException catch (e) {
        return Left(Failure(errMessage: e.errorModel.errorMessage));
      } catch (e) {
        return Left(Failure(errMessage: e.toString()));
      }
    }

    return Left(_networkFailure());
  }

  @override
  Future<Either<Failure, AuthEntity>> loginWithGoogle() async {
    if (await networkInfo.isConnected!) {
      try {
        final remoteAuthData = await remoteDataSource.loginWithGoogle();
        await _cacheAuthData(remoteAuthData);
        return Right(remoteAuthData);
      } on ServerException catch (e) {
        return Left(Failure(errMessage: e.errorModel.errorMessage));
      } catch (e) {
        return Left(Failure(errMessage: e.toString()));
      }
    }

    return Left(_networkFailure());
  }

  @override
  Future<Either<Failure, bool>> requestEmailOtp(String email) async {
    if (await networkInfo.isConnected!) {
      try {
        await remoteDataSource.requestEmailOtp(email);
        return const Right(true);
      } on ServerException catch (e) {
        return Left(Failure(errMessage: e.errorModel.errorMessage));
      } catch (e) {
        return Left(Failure(errMessage: e.toString()));
      }
    }

    return Left(_networkFailure());
  }

  @override
  Future<Either<Failure, AuthEntity>> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    if (await networkInfo.isConnected!) {
      try {
        final remoteAuthData = await remoteDataSource.verifyEmailOtp(
          email: email,
          otp: otp,
        );
        await _cacheAuthData(remoteAuthData);
        return Right(remoteAuthData);
      } on ServerException catch (e) {
        return Left(Failure(errMessage: e.errorModel.errorMessage));
      } catch (e) {
        return Left(Failure(errMessage: e.toString()));
      }
    }

    return Left(_networkFailure());
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
      throw CacheExeption(
        errorMessage: "Failed to clear cached authentication",
      );
    }
  }

  Future<void> _cacheAuthData(AuthModel authModel) async {
    await localDataSource.cacheAuthData(authModel);
  }

  Failure _networkFailure() {
    return Failure(
      errMessage:
          "No Internet Connection. Please check your network and try again.",
    );
  }
}
