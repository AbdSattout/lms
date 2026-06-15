abstract class ProfileEvent {}

class GetProfileEvent extends ProfileEvent {}

class UpdateProfilePictureEvent extends ProfileEvent {
  final String imagePath;

  UpdateProfilePictureEvent(
      this.imagePath,
      );
}
class UpdateProfileEvent extends ProfileEvent {

  final String email;
  final String phone;
  final String university;

  UpdateProfileEvent({
    required this.email,
    required this.phone,
    required this.university,
  });
}