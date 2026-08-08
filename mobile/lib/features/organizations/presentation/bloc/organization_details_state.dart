import '../../domain/entities/organization_entity.dart';

abstract class OrganizationDetailsState {}

class OrganizationDetailsInitial extends OrganizationDetailsState {}

class OrganizationDetailsLoading extends OrganizationDetailsState {}

class OrganizationDetailsLoaded extends OrganizationDetailsState {
  final OrganizationEntity organization;
  final bool isProcessing;
  OrganizationDetailsLoaded(this.organization, {this.isProcessing = false});
}

class OrganizationDetailsError extends OrganizationDetailsState {
  final String message;
  OrganizationDetailsError(this.message);
}
class OrganizationDeleted extends OrganizationDetailsState {}