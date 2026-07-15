import '../../domain/entities/organization_entity.dart';

abstract class OrganizationState {}

class OrganizationInitial extends OrganizationState {}

class OrganizationLoading extends OrganizationState {}

class OrganizationLoaded extends OrganizationState {
  final List<OrganizationEntity> organizations;

  OrganizationLoaded(
      this.organizations,
      );
}

class OrganizationError extends OrganizationState {
  final String message;

  OrganizationError(
      this.message,
      );
}