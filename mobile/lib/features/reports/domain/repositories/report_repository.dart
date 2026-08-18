import '../usecases/create_report_params.dart';

abstract class ReportRepository {
  Future<void> createReport(CreateReportParams params);
}
