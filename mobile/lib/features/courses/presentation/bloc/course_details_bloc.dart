import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/api_error_resolver.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/usecases/enroll_in_course_usecase.dart';
import '../../domain/usecases/get_course_by_id_usecase.dart';
import '../../domain/usecases/get_course_by_slug_usecase.dart';
import '../../domain/usecases/skip_placement_test_usecase.dart';
import 'course_details_event.dart';
import 'course_details_state.dart';

class CourseDetailsBloc extends Bloc<CourseDetailsEvent, CourseDetailsState> {
  final GetCourseByIdUseCase getCourseByIdUseCase;
  final GetCourseBySlugUseCase getCourseBySlugUseCase;
  final EnrollInCourseUseCase enrollInCourseUseCase;
  final SkipPlacementTestUseCase skipPlacementTestUseCase;

  int? _lastId;
  String? _lastOrgSlug;
  String? _lastCourseSlug;

  CourseDetailsBloc({
    required this.getCourseByIdUseCase,
    required this.getCourseBySlugUseCase,
    required this.enrollInCourseUseCase,
    required this.skipPlacementTestUseCase,
  }) : super(CourseDetailsInitial()) {
    on<GetCourseDetailsEvent>(_getCourseDetails);
    on<EnrollEvent>(_enroll);
    on<StartCourseEvent>(_startCourse);
  }

  Future<void> _getCourseDetails(
    GetCourseDetailsEvent event,
    Emitter<CourseDetailsState> emit,
  ) async {
    try {
      emit(CourseDetailsLoading());

      _lastId = event.id;
      _lastOrgSlug = event.orgSlug;
      _lastCourseSlug = event.courseSlug;

      final course = event.id != null
          ? await getCourseByIdUseCase(event.id!)
          : await getCourseBySlugUseCase(
              orgSlug: event.orgSlug!,
              courseSlug: event.courseSlug!,
            );

      emit(CourseDetailsLoaded(course));
    } catch (e) {
      emit(CourseDetailsError(resolveApiErrorMessage(e)));
    }
  }

  Future<void> _enroll(
    EnrollEvent event,
    Emitter<CourseDetailsState> emit,
  ) async {
    try {
      final result = await enrollInCourseUseCase(event.courseId);
      emit(CourseEnrollSuccess(result));

      final course = await _reloadCourse(fallbackId: event.courseId);
      emit(CourseDetailsLoaded(course));
    } catch (e) {
      emit(CourseDetailsError(resolveApiErrorMessage(e)));
    }
  }

  Future<void> _startCourse(
    StartCourseEvent event,
    Emitter<CourseDetailsState> emit,
  ) async {
    final current = state;
    if (current is! CourseDetailsLoaded || current.isStartingCourse) return;

    try {
      emit(CourseDetailsLoaded(current.course, isStartingCourse: true));

      await skipPlacementTestUseCase(event.courseId);

      final course = await _reloadCourse(fallbackId: event.courseId);
      emit(CourseStartSuccess(course));
      emit(CourseDetailsLoaded(course));
    } catch (e) {
      emit(CourseDetailsLoaded(current.course));
      emit(CourseDetailsActionError(resolveApiErrorMessage(e)));
    }
  }

  Future<CourseEntity> _reloadCourse({required int fallbackId}) {
    if (_lastOrgSlug != null && _lastCourseSlug != null) {
      return getCourseBySlugUseCase(
        orgSlug: _lastOrgSlug!,
        courseSlug: _lastCourseSlug!,
      );
    }

    return getCourseByIdUseCase(_lastId ?? fallbackId);
  }
}
