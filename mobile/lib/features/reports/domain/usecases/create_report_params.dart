import '../entities/report_target.dart';

class CreateReportParams {
  final ReportTarget target;
  final String reason;

  const CreateReportParams({required this.target, required this.reason});

  Map<String, dynamic> toJson() => target.toPayload(reason);
}
