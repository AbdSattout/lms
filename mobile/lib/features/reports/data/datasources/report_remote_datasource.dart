import '../../../../core/databases/api/api_consumer.dart';
import '../../../../core/databases/api/end_points.dart';
import '../../domain/usecases/create_report_params.dart';

abstract class ReportRemoteDataSource {
  Future<void> createReport(CreateReportParams params);
}

class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  final ApiConsumer api;

  ReportRemoteDataSourceImpl({required this.api});

  @override
  Future<void> createReport(CreateReportParams params) async {
    await api.post(EndPoints.reports, data: params.toJson());
  }
}
