import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/api_error_resolver.dart';
import '../../recommendations/domain/entities/recommended_course_entity.dart';
import '../../recommendations/domain/entities/recommended_organization_entity.dart';
import '../../recommendations/domain/usecases/get_recommended_courses_usecase.dart';
import '../../recommendations/domain/usecases/get_recommended_organizations_usecase.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetRecommendedCoursesUseCase getRecommendedCoursesUseCase;
  final GetRecommendedOrganizationsUseCase getRecommendedOrganizationsUseCase;

  HomeBloc({
    required this.getRecommendedCoursesUseCase,
    required this.getRecommendedOrganizationsUseCase,
  }) : super(HomeLoading()) {
    on<GetHomeDataEvent>(_getHomeData);
  }

  Future<void> _getHomeData(
    GetHomeDataEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());

    List<RecommendedCourseEntity>? recommendedCourses;
    String? coursesError;

    List<RecommendedOrganizationEntity>? recommendedOrganizations;
    String? organizationsError;

    await Future.wait([
      getRecommendedCoursesUseCase()
          .then((result) {
            recommendedCourses = result;
          })
          .catchError((e) {
            coursesError = resolveApiErrorMessage(e);
          }),

      getRecommendedOrganizationsUseCase()
          .then((result) {
            recommendedOrganizations = result;
          })
          .catchError((e) {
            organizationsError = resolveApiErrorMessage(e);
          }),
    ]);

    emit(
      HomeLoaded(
        recommendedCourses: recommendedCourses,
        coursesError: coursesError,
        recommendedOrganizations: recommendedOrganizations,
        organizationsError: organizationsError,
      ),
    );
  }
}
