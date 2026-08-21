import '../../domain/entities/certificate_entity.dart';

class CertificateModel extends CertificateEntity {
  const CertificateModel({
    required super.certificateCode,
    required super.studentName,
    required super.courseName,
    super.organizationName,
    required super.finalQuizScore,
    required super.finalQuizTotal,
    required super.finalQuizPercentage,
    super.grade,
    super.previewUrl,
    super.pdfUrl,
    super.createdAt,
    super.updatedAt,
  });

  factory CertificateModel.fromJson(Map<String, dynamic> json) {
    final baseEntity = json['baseEntity'] as Map<String, dynamic>?;
    final organization = json['organization'] as Map<String, dynamic>?;

    return CertificateModel(
      certificateCode: json['certificateCode'] as String? ?? '',
      studentName: json['studentName'] as String? ?? '',
      courseName: json['courseName'] as String? ?? '',
      organizationName: organization?['name'] as String?,
      finalQuizScore: json['finalQuizScore'] as int? ?? 0,
      finalQuizTotal: json['finalQuizTotal'] as int? ?? 0,
      finalQuizPercentage: json['finalQuizPercentage'] as int? ?? 0,
      grade: json['grade'] as String?,
      previewUrl: json['previewUrl'] as String?,
      pdfUrl: json['pdfUrl'] as String?,
      createdAt: baseEntity?['createdAt'] as String?,
      updatedAt: baseEntity?['updatedAt'] as String?,
    );
  }
}