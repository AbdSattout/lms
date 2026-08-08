import '../../../../core/databases/api/api_consumer.dart';
import '../../../../core/databases/api/end_points.dart';
import '../../../../core/models/page_response.dart';
import '../models/course_model.dart';

abstract class CourseRemoteDataSource {
  Future<List<CourseModel>> getAllCourses();

  Future<CourseModel> getCourseById(int id);

  Future<CourseModel> getCourseBySlug({
    required String orgSlug,
    required String courseSlug,
  });

  Future<List<CourseModel>> getOrganizationCourses(String orgSlug);

  Future<List<CourseModel>> getMyEnrollments();

  Future<EnrollActionResultModel> enrollInCourse(int courseId);
  Future<void> unenrollFromCourse(int courseId);
}

class CourseRemoteDataSourceImpl implements CourseRemoteDataSource {
  final ApiConsumer api;

  CourseRemoteDataSourceImpl(this.api);

  @override
  Future<List<CourseModel>> getAllCourses() async {
    final response = await api.get(
      EndPoints.courses,
    );

    final page = PageResponse<CourseModel>.fromJson(
      response,
          (json) => CourseModel.fromJson(json),
    );

    return page.content;
  }

  @override
  Future<CourseModel> getCourseById(int id) async {
    final response = await api.get(
      EndPoints.courseById(id),
    );

    return CourseModel.fromJson(response);
  }

  @override
  Future<CourseModel> getCourseBySlug({
    required String orgSlug,
    required String courseSlug,
  }) async {
    final response = await api.get(
      EndPoints.courseBySlug(
        orgSlug: orgSlug,
        courseSlug: courseSlug,
      ),
    );

    return CourseModel.fromJson(response);
  }

  @override
  Future<List<CourseModel>> getOrganizationCourses(String orgSlug) async {
    final response = await api.get(
      EndPoints.organizationCourses(orgSlug),
    );

    final page = PageResponse<CourseModel>.fromJson(
      response,
          (json) => CourseModel.fromJson(json),
    );

    return page.content;
  }

  @override
  Future<List<CourseModel>> getMyEnrollments() async {
    final response = await api.get(
      EndPoints.myEnrollments,
    );

    final page = PageResponse<CourseModel>.fromJson(
      response,
          (json) => CourseModel.fromJson(json),
    );

    return page.content;
  }

  @override
  Future<EnrollActionResultModel> enrollInCourse(int courseId) async {
    final response = await api.post(
      EndPoints.enrollInCourse(courseId),
    );

    return EnrollActionResultModel.fromJson(response);
  }
  @override
  Future<void> unenrollFromCourse(int courseId) async {
    await api.delete(EndPoints.unenrollFromCourse(courseId));
  }
}