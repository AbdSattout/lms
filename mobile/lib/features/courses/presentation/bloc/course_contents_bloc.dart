import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/api_error_resolver.dart';
import '../../domain/usecases/get_course_by_id_usecase.dart';
import '../../domain/usecases/skip_placement_test_usecase.dart';
import '../../domain/usecases/unenroll_from_course_usecase.dart';
import 'course_contents_event.dart';
import 'course_contents_state.dart';

class CourseContentsBloc
    extends Bloc<CourseContentsEvent, CourseContentsState> {
  final GetCourseByIdUseCase getCourseByIdUseCase;
  final SkipPlacementTestUseCase skipPlacementTestUseCase;
  final UnenrollFromCourseUseCase unenrollFromCourseUseCase;

  CourseContentsBloc({
    required this.getCourseByIdUseCase,
    required this.skipPlacementTestUseCase,
    required this.unenrollFromCourseUseCase,
  }) : super(CourseContentsLoading()) {
    on<GetCourseContentsEvent>((event, emit) async {
      try {
        emit(CourseContentsLoading());
        final course = await getCourseByIdUseCase(event.courseId);
        emit(CourseContentsLoaded(course));
      } catch (e) {
        emit(CourseContentsError(resolveApiErrorMessage(e)));
      }
    });

    on<StartCourseContentsEvent>((event, emit) async {
      try {
        emit(CourseContentsStartingCourse());
        await skipPlacementTestUseCase(event.courseId);
        final course = await getCourseByIdUseCase(event.courseId);
        emit(CourseContentsLoaded(course));
      } catch (e) {
        emit(CourseContentsError(resolveApiErrorMessage(e)));
      }
    });

    on<UnenrollFromCourseEvent>((event, emit) async {
      try {
        emit(CourseContentsLoading());
        await unenrollFromCourseUseCase(event.courseId);
        emit(CourseUnenrolled('تم إلغاء التسجيل بنجاح'));
      } catch (e) {
        emit(CourseContentsError(resolveApiErrorMessage(e)));
      }
    });
  }
}
