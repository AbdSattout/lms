import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_params.dart';
import '../../domain/usecases/update_profile_picture_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

String describeProfileError(Object error) {
  final raw = error.toString();
  if (!raw.startsWith('Instance of')) return raw;

  try {
    final dynamic e = error;
    final dynamic model = e.errorModel;
    if (model != null) {
      final dynamic msg = model.errorMessage;
      if (msg != null) return msg.toString();
    }
  } catch (_) {}

  try {
    final dynamic e = error;
    final dynamic msg = e.errorMessage;
    if (msg != null) return msg.toString();
  } catch (_) {}

  try {
    final dynamic e = error;
    final dynamic msg = e.message;
    if (msg != null) return msg.toString();
  } catch (_) {}

  return 'حدث خطأ غير متوقع، حاول مرة أخرى (${error.runtimeType})';
}

class ProfileBloc
    extends Bloc<ProfileEvent, ProfileState> {

  final GetProfileUseCase getProfileUseCase;
  final UpdateProfilePictureUseCase updatePictureUseCase;
  final UpdateProfileUseCase updateProfileUseCase;

  ProfileBloc({
    required this.getProfileUseCase,
    required this.updatePictureUseCase,
    required this.updateProfileUseCase
  }) : super(ProfileInitial()) {

    on<GetProfileEvent>(
      _getProfile,
    );

    on<UpdateProfilePictureEvent>(
      _updatePicture,
    );
    on<UpdateProfileEvent>(
      _updateProfile,
    );
  }

  Future<void> _getProfile(
      GetProfileEvent event,
      Emitter<ProfileState> emit,
      ) async {
    try {
      emit(ProfileLoading());

      final profile =
      await getProfileUseCase();

      emit(
        ProfileLoaded(profile),
      );
    } catch (e) {
      emit(
        ProfileError(
          describeProfileError(e),
        ),
      );
    }
  }

  Future<void> _updatePicture(
      UpdateProfilePictureEvent event,
      Emitter<ProfileState> emit,
      ) async {
    try {
      await updatePictureUseCase(
        event.imagePath,
      );

      // FIX: this state was never emitted before, so the
      // "تم تحديث الصورة بنجاح" snackbar in the UI never fired.
      emit(ProfilePictureUpdated());

      final profile =
      await getProfileUseCase();

      emit(
        ProfileLoaded(profile),
      );
    } catch (e) {
      emit(
        ProfileError(
          describeProfileError(e),
        ),
      );
    }
  }

  Future<void> _updateProfile(
      UpdateProfileEvent event,
      Emitter<ProfileState> emit,
      ) async {

    try {

      await updateProfileUseCase(
        UpdateProfileParams(
          email: event.email,
          phone: event.phone,
          university: event.university,
        ),
      );

      emit(
        ProfileUpdated(),
      );

      final profile =
      await getProfileUseCase();

      emit(
        ProfileLoaded(profile),
      );

    } catch (e) {

      emit(
        ProfileError(
          describeProfileError(e),
        ),
      );
    }
  }
}