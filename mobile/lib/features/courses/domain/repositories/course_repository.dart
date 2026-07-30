import '../entities/course_entity.dart';

abstract class CourseRepository {
  Future<List<CourseEntity>> getAllCourses();

  Future<CourseEntity> getCourseById(int id);

  Future<CourseEntity> getCourseBySlug({
    required String orgSlug,
    required String courseSlug,
  });

  Future<List<CourseEntity>> getOrganizationCourses(
      String orgSlug,
      );

  Future<List<CourseEntity>> getMyEnrollments();

  Future<EnrollActionResultEntity> enrollInCourse(int courseId);
}