class CertificateEntity {
  final String certificateCode;
  final String studentName;
  final String courseName;
  final String? organizationName;
  final int finalQuizScore;
  final int finalQuizTotal;
  final int finalQuizPercentage;
  final String? grade;

  const CertificateEntity({
    required this.certificateCode,
    required this.studentName,
    required this.courseName,
    this.organizationName,
    required this.finalQuizScore,
    required this.finalQuizTotal,
    required this.finalQuizPercentage,
    this.grade,
  });
}