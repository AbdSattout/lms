import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/features/profile/presentation/bloc/profile_event.dart';
import 'package:lms/features/profile/presentation/bloc/profile_state.dart';

import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_picture_usecase.dart';

class ProfileBloc
    extends Bloc<ProfileEvent, ProfileState> {

  final GetProfileUseCase getProfileUseCase;
  final UpdateProfilePictureUseCase updatePictureUseCase;

  ProfileBloc({
    required this.getProfileUseCase,
    required this.updatePictureUseCase,
  }) : super(ProfileInitial()) {

    on<GetProfileEvent>(_getProfile);
    on<UpdateProfilePictureEvent>(
      _updatePicture,
    );
  }

  Future<void> _getProfile(
      GetProfileEvent event,
      Emitter<ProfileState> emit,
      ) async {

    emit(ProfileLoading());

    final profile =
    await getProfileUseCase();

    emit(
      ProfileLoaded(profile),
    );
  }

  Future<void> _updatePicture(
      UpdateProfilePictureEvent event,
      Emitter<ProfileState> emit,
      ) async {

    await updatePictureUseCase(
      event.imagePath,
    );

    add(
      GetProfileEvent(),
    );
  }
}