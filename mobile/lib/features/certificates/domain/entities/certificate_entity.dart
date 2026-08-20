class CertificateEntity {
  final String certificateCode;
  final String studentName;
  final String courseName;
  final String? organizationName;
  final int finalQuizScore;
  final int finalQuizTotal;
  final int finalQuizPercentage;
  final String? grade;
  final String? previewUrl;
  final String? pdfUrl;
  final String? createdAt;
  final String? updatedAt;

  const CertificateEntity({
    required this.certificateCode,
    required this.studentName,
    required this.courseName,
    this.organizationName,
    required this.finalQuizScore,
    required this.finalQuizTotal,
    required this.finalQuizPercentage,
    this.grade,
    this.previewUrl,
    this.pdfUrl,
    this.createdAt,
    this.updatedAt,
  });

  bool get hasPreview => previewUrl != null && previewUrl!.isNotEmpty;
  bool get hasPdf => pdfUrl != null && pdfUrl!.isNotEmpty;
}