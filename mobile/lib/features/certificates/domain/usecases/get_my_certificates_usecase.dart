import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/paginated_certificates_entity.dart';
import '../repositories/certificate_repository.dart';

class GetMyCertificatesUseCase {
  final CertificateRepository repository;
  GetMyCertificatesUseCase(this.repository);

  Future<Either<Failure, PaginatedCertificatesEntity>> call({int page = 0, int size = 20}) {
    return repository.getMyCertificates(page: page, size: size);
  }
}