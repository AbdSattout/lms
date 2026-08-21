import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/api_error_resolver.dart';
import '../../domain/usecases/get_all_courses_usecase.dart';
import 'all_courses_event.dart';
import 'all_courses_state.dart';

class AllCoursesBloc extends Bloc<AllCoursesEvent, AllCoursesState> {
  final GetAllCoursesUseCase getAllCoursesUseCase;

  AllCoursesBloc({required this.getAllCoursesUseCase}) : super(AllCoursesInitial()) {
    on<LoadAllCoursesEvent>(_onLoad);
  }

  Future<void> _onLoad(LoadAllCoursesEvent event, Emitter<AllCoursesState> emit) async {
    try {
      emit(AllCoursesLoading());
      final courses = await getAllCoursesUseCase();
      emit(AllCoursesLoaded(courses));
    } catch (e) {
      emit(AllCoursesError(resolveApiErrorMessage(e)));
    }
  }
}