import '../../../../core/databases/api/api_consumer.dart';
import '../../../../core/databases/api/end_points.dart';
import '../models/paginated_certificates_model.dart';

abstract class CertificateRemoteDataSource {
  Future<PaginatedCertificatesModel> getMyCertificates({int page = 0, int size = 20});
}

class CertificateRemoteDataSourceImpl implements CertificateRemoteDataSource {
  final ApiConsumer api;

  CertificateRemoteDataSourceImpl({required this.api});

  @override
  Future<PaginatedCertificatesModel> getMyCertificates({int page = 0, int size = 20}) async {
    final response = await api.get(
      EndPoints.myCertificates,
      queryParameters: {'page': page, 'size': size},
    );
    return PaginatedCertificatesModel.fromJson(response);
  }
}