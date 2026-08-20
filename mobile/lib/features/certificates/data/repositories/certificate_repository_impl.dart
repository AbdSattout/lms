import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/paginated_certificates_entity.dart';
import '../../domain/repositories/certificate_repository.dart';
import '../datasources/certificate_remote_datasource.dart';

class CertificateRepositoryImpl implements CertificateRepository {
  final CertificateRemoteDataSource remoteDataSource;

  CertificateRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, PaginatedCertificatesEntity>> getMyCertificates({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final result = await remoteDataSource.getMyCertificates(page: page, size: size);
      return Right(result);
    } on TooManyRequestsException catch (e) {
      return Left(Failure(errMessage: e.errorModel.errorMessage));
    }on ServerException catch (e) {
      return Left(Failure(errMessage: e.errorModel.errorMessage));
    } catch (e) {
      return Left(Failure(errMessage: e.toString()));
    }
  }
}