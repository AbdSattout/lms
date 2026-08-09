import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/api_error_resolver.dart';
import '../../domain/usecases/get_organization_courses_usecase.dart';
import 'organization_courses_event.dart';
import 'organization_courses_state.dart';

class OrganizationCoursesBloc
    extends Bloc<OrganizationCoursesEvent, OrganizationCoursesState> {
  final GetOrganizationCoursesUseCase getOrganizationCoursesUseCase;

  OrganizationCoursesBloc({required this.getOrganizationCoursesUseCase})
    : super(OrganizationCoursesInitial()) {
    on<GetOrganizationCoursesEvent>(_getCourses);
  }

  Future<void> _getCourses(
    GetOrganizationCoursesEvent event,
    Emitter<OrganizationCoursesState> emit,
  ) async {
    try {
      emit(OrganizationCoursesLoading());
      final courses = await getOrganizationCoursesUseCase(event.slug);
      emit(OrganizationCoursesLoaded(courses));
    } catch (e) {
      emit(OrganizationCoursesError(resolveApiErrorMessage(e)));
    }
  }
}
