abstract class ProfileEvent {}

class GetProfileEvent
    extends ProfileEvent {}

class UpdateProfilePictureEvent
    extends ProfileEvent {
  final String imagePath;

  UpdateProfilePictureEvent(
      this.imagePath,
      );
}