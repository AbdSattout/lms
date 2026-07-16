import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/api_error_resolver.dart';
import '../../domain/entities/course_entity.dart';
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

  CourseDetailsBloc({
    required this.getCourseByIdUseCase,
    required this.getCourseBySlugUseCase,
    required this.enrollInCourseUseCase,
  }) : super(CourseDetailsInitial()) {

    on<GetCourseDetailsEvent>(
      _getCourseDetails,
    );

    on<EnrollEvent>(
      _enroll,
    );
  }

  Future<void> _getCourseDetails(
      GetCourseDetailsEvent event,
      Emitter<CourseDetailsState> emit,
      ) async {
    try {
      emit(CourseDetailsLoading());

      final course = event.id != null
          ? await getCourseByIdUseCase(event.id!)
          : await getCourseBySlugUseCase(
        orgSlug: event.orgSlug!,
        courseSlug: event.courseSlug!,
      );

      final resolvedCourse = event.knownEnrollment != null
          ? CourseEntity(
        id: course.id,
        title: course.title,
        slug: course.slug,
        description: course.description,
        coverUrl: course.coverUrl,
        organizationName: course.organizationName,
        status: course.status,
        // authoritative source: the enrollments list, not /courses/{id}
        enrollment: event.knownEnrollment,
      )
          : course;

      emit(
        CourseDetailsLoaded(resolvedCourse),
      );
    } catch (e) {
      emit(
        CourseDetailsError(
          resolveApiErrorMessage(e),
        ),
      );
    }
  }

  Future<void> _enroll(
      EnrollEvent event,
      Emitter<CourseDetailsState> emit,
      ) async {
    try {
      final result = await enrollInCourseUseCase(event.courseId);

      emit(
        CourseEnrollSuccess(result),
      );

      // Refresh the course's static fields from /courses/{id}. Its
      // "enrollment" data (if that route even includes one) still isn't
      // trusted — TODO once the placement-test flow is built: after a
      // fresh enroll, the correct next step is starting the placement
      // test, not just showing 0% progress. Revisit this when we get to
      // that step.
      final course = await getCourseByIdUseCase(event.courseId);

      final resolvedCourse = CourseEntity(
        id: course.id,
        title: course.title,
        slug: course.slug,
        description: course.description,
        coverUrl: course.coverUrl,
        organizationName: course.organizationName,
        status: course.status,
        enrollment: null,
      );

      emit(
        CourseDetailsLoaded(resolvedCourse),
      );
    } catch (e) {
      emit(
        CourseDetailsError(
          resolveApiErrorMessage(e),
        ),
      );
    }
  }
}