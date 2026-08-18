import '../repositories/report_repository.dart';
import 'create_report_params.dart';

class CreateReportUseCase {
  final ReportRepository repository;

  CreateReportUseCase(this.repository);

  Future<void> call(CreateReportParams params) {
    return repository.createReport(params);
  }
}
