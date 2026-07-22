import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/api_error_resolver.dart';
import '../../domain/usecases/get_course_by_id_usecase.dart';
import 'course_contents_event.dart';
import 'course_contents_state.dart';

class CourseContentsBloc
    extends Bloc<CourseContentsEvent, CourseContentsState> {

  final GetCourseByIdUseCase getCourseByIdUseCase;

  CourseContentsBloc({
    required this.getCourseByIdUseCase,
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
  }
}