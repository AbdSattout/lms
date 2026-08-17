import '../../../../core/databases/api/api_consumer.dart';
import '../../../../core/databases/api/end_points.dart';
import '../../../../core/models/page_response.dart';
import '../models/recommended_course_model.dart';
import '../models/recommended_organization_model.dart';

abstract class RecommendationRemoteDataSource {
  Future<List<RecommendedCourseModel>> getRecommendedCourses();

  Future<List<RecommendedOrganizationModel>> getRecommendedOrganizations();
}

class RecommendationRemoteDataSourceImpl
    implements RecommendationRemoteDataSource {
  final ApiConsumer api;

  RecommendationRemoteDataSourceImpl(this.api);

  @override
  Future<List<RecommendedCourseModel>> getRecommendedCourses() async {
    final response = await api.get(EndPoints.recommendedCourses);

    final page = PageResponse<RecommendedCourseModel>.fromJson(
      response,
      RecommendedCourseModel.fromJson,
    );

    return page.content;
  }

  @override
  Future<List<RecommendedOrganizationModel>>
  getRecommendedOrganizations() async {
    final response = await api.get(EndPoints.recommendedOrganizations);

    final page = PageResponse<RecommendedOrganizationModel>.fromJson(
      response,
      RecommendedOrganizationModel.fromJson,
    );

    return page.content;
  }
}
