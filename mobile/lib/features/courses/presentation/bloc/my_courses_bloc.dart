import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/api_error_resolver.dart';
import '../../domain/usecases/get_my_enrollments_usecase.dart';
import 'my_courses_event.dart';
import 'my_courses_state.dart';

class MyCoursesBloc extends Bloc<MyCoursesEvent, MyCoursesState> {

  final GetMyEnrollmentsUseCase getMyEnrollmentsUseCase;

  MyCoursesBloc({
    required this.getMyEnrollmentsUseCase,
  }) : super(MyCoursesInitial()) {

    on<GetMyEnrollmentsEvent>(
      _getMyEnrollments,
    );
  }

  Future<void> _getMyEnrollments(
      GetMyEnrollmentsEvent event,
      Emitter<MyCoursesState> emit,
      ) async {
    try {
      emit(MyCoursesLoading());

      final courses =
      await getMyEnrollmentsUseCase();

      emit(
        MyCoursesLoaded(courses),
      );
    } catch (e) {
      emit(
        MyCoursesError(
          resolveApiErrorMessage(e),
        ),
      );
    }
  }
}