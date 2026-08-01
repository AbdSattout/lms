import '../../../../core/databases/api/api_consumer.dart';
import '../../../../core/databases/api/end_points.dart';
import '../../../../core/models/page_response.dart';
import '../models/organization_model.dart';

abstract class OrganizationRemoteDataSource {
  Future<List<OrganizationModel>> getAllOrganizations();

  Future<OrganizationModel> getOrganizationBySlug(String slug);
}

class OrganizationRemoteDataSourceImpl
    implements OrganizationRemoteDataSource {
  final ApiConsumer api;

  OrganizationRemoteDataSourceImpl(this.api);

  @override
  Future<List<OrganizationModel>> getAllOrganizations() async {
    final response = await api.get(
      EndPoints.organizations,
    );

    final page = PageResponse<OrganizationModel>.fromJson(
      response,
          (json) => OrganizationModel.fromJson(json),
    );

    return page.content;
  }

  @override
  Future<OrganizationModel> getOrganizationBySlug(String slug) async {
    final response = await api.get(
      EndPoints.organizationBySlug(slug),
    );

    return OrganizationModel.fromJson(response);
  }
}