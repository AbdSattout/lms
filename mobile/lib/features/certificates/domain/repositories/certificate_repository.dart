import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/paginated_certificates_entity.dart';

abstract class CertificateRepository {
  Future<Either<Failure, PaginatedCertificatesEntity>> getMyCertificates({
    int page = 0,
    int size = 20,
  });
}