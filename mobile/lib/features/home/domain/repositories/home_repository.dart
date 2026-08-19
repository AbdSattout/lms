import '../../../courses/domain/entities/course_entity.dart';
import '../../../organizations/domain/entities/organization_entity.dart';

abstract class HomeRepository {
  Future<List<CourseEntity>> searchCourses(String query);
  Future<List<OrganizationEntity>> searchOrganizations(String query);
}