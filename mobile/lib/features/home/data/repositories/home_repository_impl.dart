import '../../../courses/domain/entities/course_entity.dart';
import '../../../organizations/domain/entities/organization_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<CourseEntity>> searchCourses(String query) async {
    return await remoteDataSource.searchCourses(query);
  }

  @override
  Future<List<OrganizationEntity>> searchOrganizations(String query) async {
    return await remoteDataSource.searchOrganizations(query);
  }
}