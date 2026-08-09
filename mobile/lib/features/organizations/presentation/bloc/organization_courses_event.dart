abstract class OrganizationCoursesEvent {}

class GetOrganizationCoursesEvent extends OrganizationCoursesEvent {
  final String slug;
  GetOrganizationCoursesEvent(this.slug);
}