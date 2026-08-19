import '../../../../core/databases/api/api_consumer.dart';
import '../../../../core/databases/api/end_points.dart';
import '../../../../core/models/page_response.dart';
import '../../../courses/data/models/course_model.dart';
import '../../../organizations/data/models/organization_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<CourseModel>> searchCourses(String query);
  Future<List<OrganizationModel>> searchOrganizations(String query);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final ApiConsumer api;

  HomeRemoteDataSourceImpl({required this.api});

  @override
  Future<List<CourseModel>> searchCourses(String query) async {
    final response = await api.get(
      EndPoints.courses,
      queryParameters: {'q': query, 'page': 0, 'size': 20},
    );
    final page = PageResponse<CourseModel>.fromJson(
      response,
          (json) => CourseModel.fromJson(json),
    );
    return page.content;
  }

  @override
  Future<List<OrganizationModel>> searchOrganizations(String query) async {
    final response = await api.get(
      EndPoints.organizations,
      queryParameters: {'q': query, 'page': 0, 'size': 20},
    );
    final page = PageResponse<OrganizationModel>.fromJson(
      response,
      OrganizationModel.fromJson,
    );
    return page.content;
  }
}