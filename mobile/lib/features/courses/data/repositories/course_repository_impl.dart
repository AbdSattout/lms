import '../../domain/entities/course_entity.dart';
import '../../domain/repositories/course_repository.dart';
import '../datasources/course_remote_datasource.dart';

class CourseRepositoryImpl implements CourseRepository {
  final CourseRemoteDataSource remote;

  CourseRepositoryImpl(this.remote);

  @override
  Future<List<CourseEntity>> getAllCourses() {
    return remote.getAllCourses();
  }

  @override
  Future<CourseEntity> getCourseById(int id) {
    return remote.getCourseById(id);
  }

  @override
  Future<CourseEntity> getCourseBySlug({
    required String orgSlug,
    required String courseSlug,
  }) {
    return remote.getCourseBySlug(
      orgSlug: orgSlug,
      courseSlug: courseSlug,
    );
  }

  @override
  Future<List<CourseEntity>> getOrganizationCourses(String orgSlug) {
    return remote.getOrganizationCourses(orgSlug);
  }

  @override
  Future<List<CourseEntity>> getMyEnrollments() {
    return remote.getMyEnrollments();
  }

  @override
  Future<EnrollActionResultEntity> enrollInCourse(int courseId) {
    return remote.enrollInCourse(courseId);
  }
  @override
  Future<void> unenrollFromCourse(int courseId) async {
    await remote.unenrollFromCourse(courseId);
  }
}