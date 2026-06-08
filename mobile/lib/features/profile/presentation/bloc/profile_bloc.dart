import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_picture_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc
    extends Bloc<ProfileEvent, ProfileState> {

  final GetProfileUseCase getProfileUseCase;
  final UpdateProfilePictureUseCase updatePictureUseCase;

  ProfileBloc({
    required this.getProfileUseCase,
    required this.updatePictureUseCase,
  }) : super(ProfileInitial()) {

    on<GetProfileEvent>(
      _getProfile,
    );

    on<UpdateProfilePictureEvent>(
      _updatePicture,
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
          e.toString(),
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

      emit(
        ProfilePictureUpdated(),
      );

      add(
        GetProfileEvent(),
      );
    } catch (e) {
      emit(
        ProfileError(
          e.toString(),
        ),
      );
    }
  }
}