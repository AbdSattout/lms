import '../../../../core/databases/api/api_consumer.dart';
import '../../../../core/databases/api/end_points.dart';
import '../../../../core/models/page_response.dart';
import '../../../courses/data/models/course_model.dart';
import '../models/organization_invite_model.dart';
import '../models/organization_model.dart';

abstract class OrganizationRemoteDataSource {
  Future<List<OrganizationModel>> getAllOrganizations();

  Future<OrganizationModel> getOrganizationBySlug(String slug);

  Future<void> joinOrganization(String slug);

  Future<void> leaveOrganization(String slug);

  Future<void> cancelJoinRequest(String slug);

  Future<void> deleteOrganization(String slug);

  Future<List<CourseModel>> getOrganizationCourses(String slug);

  Future<List<OrganizationInviteModel>> getMyInvites();

  Future<void> acceptInviteByToken(String token);

  Future<void> acceptInvite({required String slug, required int inviteId});

  Future<void> declineInvite({required String slug, required int inviteId});
}

class OrganizationRemoteDataSourceImpl implements OrganizationRemoteDataSource {
  final ApiConsumer api;

  OrganizationRemoteDataSourceImpl(this.api);

  @override
  Future<List<OrganizationModel>> getAllOrganizations() async {
    final response = await api.get(EndPoints.organizations);

    final page = PageResponse<OrganizationModel>.fromJson(
      response,
      OrganizationModel.fromJson,
    );

    return page.content;
  }

  @override
  Future<OrganizationModel> getOrganizationBySlug(String slug) async {
    final response = await api.get(EndPoints.organizationBySlug(slug));

    return OrganizationModel.fromJson(response);
  }

  @override
  Future<void> joinOrganization(String slug) async {
    await api.post(EndPoints.organizationJoin(slug));
  }

  @override
  Future<void> leaveOrganization(String slug) async {
    await api.delete(EndPoints.organizationLeave(slug));
  }

  @override
  Future<void> cancelJoinRequest(String slug) async {
    await api.delete(EndPoints.organizationJoin(slug));
  }

  @override
  Future<void> deleteOrganization(String slug) async {
    await api.delete(EndPoints.deleteOrganizationDashboard(slug));
  }

  @override
  Future<List<CourseModel>> getOrganizationCourses(String slug) async {
    final response = await api.get(EndPoints.organizationCourses(slug));

    final page = PageResponse<CourseModel>.fromJson(
      response,
      CourseModel.fromJson,
    );

    return page.content;
  }

  @override
  Future<List<OrganizationInviteModel>> getMyInvites() async {
    final response = await api.get(EndPoints.organizationMyInvites);

    return (response as List? ?? [])
        .map((json) => OrganizationInviteModel.fromJson(json))
        .toList();
  }

  @override
  Future<void> acceptInviteByToken(String token) async {
    await api.post(
      EndPoints.organizationInviteAcceptByToken,
      queryParameters: {'token': token},
    );
  }

  @override
  Future<void> acceptInvite({
    required String slug,
    required int inviteId,
  }) async {
    await api.post(EndPoints.organizationInviteAccept(slug, inviteId));
  }

  @override
  Future<void> declineInvite({
    required String slug,
    required int inviteId,
  }) async {
    await api.post(EndPoints.organizationInviteDecline(slug, inviteId));
  }
}
