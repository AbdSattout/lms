class ProfileEntity {
  final String name;
  final String? email;
  final String? phone;
  final String? university;

  const ProfileEntity({
    required this.name,
    this.email,
    this.phone,
    this.university,
  });
}