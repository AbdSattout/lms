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

      final resolvedCourse = event.knownProgress != null
          ? CourseEntity(
        id: course.id,
        title: course.title,
        slug: course.slug,
        description: course.description,
        coverUrl: course.coverUrl,
        organizationName: course.organizationName,
        status: course.status,
        // authoritative source: the enrollments list, not /courses/{id}
        progress: event.knownProgress,
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
      final enrollment = await enrollInCourseUseCase(event.courseId);

      emit(
        CourseEnrollSuccess(enrollment),
      );

      // Refresh the course's static fields (title/description/etc.) from
      // /courses/{id}, but don't trust its "progress" — same reasoning as
      // _getCourseDetails. A just-enrolled course is genuinely at 0%.
      final course = await getCourseByIdUseCase(event.courseId);

      final resolvedCourse = CourseEntity(
        id: course.id,
        title: course.title,
        slug: course.slug,
        description: course.description,
        coverUrl: course.coverUrl,
        organizationName: course.organizationName,
        status: course.status,
        progress: const CourseProgressEntity(),
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
