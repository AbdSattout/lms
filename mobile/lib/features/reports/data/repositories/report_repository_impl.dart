import '../../domain/repositories/report_repository.dart';
import '../../domain/usecases/create_report_params.dart';
import '../datasources/report_remote_datasource.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource remoteDataSource;

  ReportRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> createReport(CreateReportParams params) {
    return remoteDataSource.createReport(params);
  }
}
