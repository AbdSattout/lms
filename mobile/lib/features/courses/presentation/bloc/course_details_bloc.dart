import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/api_error_resolver.dart';
import '../../domain/usecases/enroll_in_course_usecase.dart';
import '../../domain/usecases/get_course_by_id_usecase.dart';
import '../../domain/usecases/get_course_by_slug_usecase.dart';
import 'course_details_event.dart';
import 'course_details_state.dart';

class CourseDetailsBloc
    extends Bloc<CourseDetailsEvent, CourseDetailsState> {

  final GetCourseByIdUseCase getCourseByIdUseCase;
  final GetCourseBySlugUseCase getCourseBySlugUseCase;
  final EnrollInCourseUseCase enrollInCourseUseCase;

  int? _lastId;
  String? _lastOrgSlug;
  String? _lastCourseSlug;

  CourseDetailsBloc({
    required this.getCourseByIdUseCase,
    required this.getCourseBySlugUseCase,
    required this.enrollInCourseUseCase,
  }) : super(CourseDetailsInitial()) {

    on<GetCourseDetailsEvent>(_getCourseDetails);
    on<EnrollEvent>(_enroll);
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

      final course = _lastOrgSlug != null && _lastCourseSlug != null
          ? await getCourseBySlugUseCase(
        orgSlug: _lastOrgSlug!,
        courseSlug: _lastCourseSlug!,
      )
          : await getCourseByIdUseCase(_lastId ?? event.courseId);

      emit(CourseDetailsLoaded(course));
    } catch (e) {
      emit(CourseDetailsError(resolveApiErrorMessage(e)));
    }
  }
}