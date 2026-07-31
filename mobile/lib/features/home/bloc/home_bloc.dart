import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/api_error_resolver.dart';
import '../../courses/domain/entities/course_entity.dart';
import '../../courses/domain/usecases/get_all_courses_usecase.dart';
import '../../courses/domain/usecases/get_my_enrollments_usecase.dart';
import '../../organizations/domain/entities/organization_entity.dart';
import '../../organizations/domain/usecases/get_all_organizations_usecase.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetAllCoursesUseCase getAllCoursesUseCase;
  final GetAllOrganizationsUseCase getAllOrganizationsUseCase;
  final GetMyEnrollmentsUseCase getMyEnrollmentsUseCase;

  HomeBloc({
    required this.getAllCoursesUseCase,
    required this.getAllOrganizationsUseCase,
    required this.getMyEnrollmentsUseCase,
  }) : super(HomeLoading()) {
    on<GetHomeDataEvent>(_getHomeData);
  }

  Future<void> _getHomeData(
      GetHomeDataEvent event, Emitter<HomeState> emit) async {
    emit(HomeLoading());

    List<CourseEntity>? courses;
    String? coursesError;
    List<OrganizationEntity>? organizations;
    String? organizationsError;
    Map<int, CourseEntity> enrolledById = {};

    try {
      courses = await getAllCoursesUseCase();
    } catch (e) {
      coursesError = resolveApiErrorMessage(e);
    }

    try {
      organizations = await getAllOrganizationsUseCase();
    } catch (e) {
      organizationsError = resolveApiErrorMessage(e);
    }

    try {
      final enrollments = await getMyEnrollmentsUseCase();
      enrolledById = {for (final c in enrollments) c.id: c};
    } catch (_) {
      // Silent — if this fails, browsed courses just won't get the
      // "already enrolled" cross-reference; doesn't need to surface as
      // a page-level error since browsing still works fine without it.
    }

    emit(HomeLoaded(
      courses: courses,
      coursesError: coursesError,
      organizations: organizations,
      organizationsError: organizationsError,
      enrolledCoursesById: enrolledById,
    ));
  }
}