import '../../domain/entities/paginated_certificates_entity.dart';
import 'certificate_model.dart';

class PaginatedCertificatesModel extends PaginatedCertificatesEntity {
  const PaginatedCertificatesModel({
    required super.content,
    required super.totalElements,
    required super.totalPages,
    required super.number,
    required super.size,
    required super.first,
    required super.last,
  });

  factory PaginatedCertificatesModel.fromJson(Map<String, dynamic> json) {
    return PaginatedCertificatesModel(
      content: (json['content'] as List<dynamic>? ?? [])
          .map((e) => CertificateModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalElements: json['totalElements'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      number: json['number'] as int? ?? 0,
      size: json['size'] as int? ?? 20,
      first: json['first'] as bool? ?? true,
      last: json['last'] as bool? ?? true,
    );
  }
}