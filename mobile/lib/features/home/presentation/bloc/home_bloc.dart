import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/api_error_resolver.dart';
import '../../../recommendations/domain/entities/recommended_course_entity.dart';
import '../../../recommendations/domain/entities/recommended_organization_entity.dart';
import '../../../recommendations/domain/usecases/get_recommended_courses_usecase.dart';
import '../../../recommendations/domain/usecases/get_recommended_organizations_usecase.dart';
import '../../../courses/domain/entities/course_entity.dart';
import '../../../organizations/domain/entities/organization_entity.dart';
import '../../domain/usecases/search_courses_usecase.dart';
import '../../domain/usecases/search_organizations_usecase.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetRecommendedCoursesUseCase getRecommendedCoursesUseCase;
  final GetRecommendedOrganizationsUseCase getRecommendedOrganizationsUseCase;
  final SearchCoursesUseCase searchCoursesUseCase;
  final SearchOrganizationsUseCase searchOrganizationsUseCase;

  String _currentQuery = '';

  HomeBloc({
    required this.getRecommendedCoursesUseCase,
    required this.getRecommendedOrganizationsUseCase,
    required this.searchCoursesUseCase,
    required this.searchOrganizationsUseCase,
  }) : super(HomeLoading()) {
    on<GetHomeDataEvent>(_getHomeData);
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<ClearSearch>(_onClearSearch);
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
          .then((result) => recommendedCourses = result)
          .catchError((e) => coursesError = resolveApiErrorMessage(e)),
      getRecommendedOrganizationsUseCase()
          .then((result) => recommendedOrganizations = result)
          .catchError((e) => organizationsError = resolveApiErrorMessage(e)),
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

  Future<void> _onSearchQueryChanged(
      SearchQueryChanged event,
      Emitter<HomeState> emit,
      ) async {
    final query = event.query.trim();
    _currentQuery = query;

    final current = state;
    if (current is HomeLoaded) {
      emit(current.copyWith(
        isSearching: true,
        searchQuery: query,
        searchCourses: null,
        searchOrganizations: null,
        searchCoursesError: null,
        searchOrganizationsError: null,
      ));
    }

    if (query.isEmpty) {
      add(ClearSearch());
      return;
    }

    await Future.delayed(const Duration(milliseconds: 400));

    if (_currentQuery != query) return;
    if (isClosed) return;

    List<CourseEntity>? courses;
    String? coursesError;
    List<OrganizationEntity>? organizations;
    String? organizationsError;

    await Future.wait([
      searchCoursesUseCase(query)
          .then((result) => courses = result)
          .catchError((e) => coursesError = resolveApiErrorMessage(e)),
      searchOrganizationsUseCase(query)
          .then((result) => organizations = result)
          .catchError((e) => organizationsError = resolveApiErrorMessage(e)),
    ]);

    if (_currentQuery != query) return;
    if (isClosed) return;

    final currentState = state;
    if (currentState is HomeLoaded) {
      emit(currentState.copyWith(
        isSearching: false,
        searchCourses: courses,
        searchOrganizations: organizations,
        searchCoursesError: coursesError,
        searchOrganizationsError: organizationsError,
      ));
    }
  }

  Future<void> _onClearSearch(
      ClearSearch event,
      Emitter<HomeState> emit,
      ) async {
    _currentQuery = '';

    final current = state;
    if (current is HomeLoaded) {
      emit(current.copyWith(
        isSearching: false,
        searchQuery: '',
        searchCourses: null,
        searchOrganizations: null,
        searchCoursesError: null,
        searchOrganizationsError: null,
      ));
    }
  }
}