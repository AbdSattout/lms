class ProfileEntity {
  final String name;
  final String? email;
  final String? phone;
  final String? university;
  final String? image;

  const ProfileEntity({
    required this.name,
    this.email,
    this.phone,
    this.university,
    this.image
  });
}