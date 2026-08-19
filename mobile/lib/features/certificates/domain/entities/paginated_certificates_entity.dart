import 'certificate_entity.dart';

class PaginatedCertificatesEntity {
  final List<CertificateEntity> content;
  final int totalElements;
  final int totalPages;
  final int number;
  final int size;
  final bool first;
  final bool last;

  const PaginatedCertificatesEntity({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.number,
    required this.size,
    required this.first,
    required this.last,
  });
}