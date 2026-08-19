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
  });

  factory CertificateModel.fromJson(Map<String, dynamic> json) {
    return CertificateModel(
      certificateCode: json['certificateCode'] as String? ?? '',
      studentName: json['studentName'] as String? ?? '',
      courseName: json['courseName'] as String? ?? '',
      organizationName: json['organization']?['name'] as String?,
      finalQuizScore: json['finalQuizScore'] as int? ?? 0,
      finalQuizTotal: json['finalQuizTotal'] as int? ?? 0,
      finalQuizPercentage: json['finalQuizPercentage'] as int? ?? 0,
      grade: json['grade'] as String?,
    );
  }
}