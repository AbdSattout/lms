import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/api_error_resolver.dart';
import '../../courses/domain/entities/course_entity.dart';
import '../../courses/domain/usecases/get_all_courses_usecase.dart';
import '../../organizations/domain/entities/organization_entity.dart';
import '../../organizations/domain/usecases/get_all_organizations_usecase.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetAllCoursesUseCase getAllCoursesUseCase;
  final GetAllOrganizationsUseCase getAllOrganizationsUseCase;

  HomeBloc({
    required this.getAllCoursesUseCase,
    required this.getAllOrganizationsUseCase,
  }) : super(HomeLoading()) {
    on<GetHomeDataEvent>(_getHomeData);
  }

  Future<void> _getHomeData(
      GetHomeDataEvent event,
      Emitter<HomeState> emit,
      ) async {
    emit(HomeLoading());

    List<CourseEntity>? courses;
    String? coursesError;

    List<OrganizationEntity>? organizations;
    String? organizationsError;

    await Future.wait([
      getAllCoursesUseCase().then((result) {
        courses = result;
      }).catchError((e) {
        coursesError = resolveApiErrorMessage(e);
      }),

      getAllOrganizationsUseCase().then((result) {
        organizations = result;
      }).catchError((e) {
        organizationsError = resolveApiErrorMessage(e);
      }),
    ]);

    emit(HomeLoaded(
      courses: courses,
      coursesError: coursesError,
      organizations: organizations,
      organizationsError: organizationsError,
    ));
  }
}