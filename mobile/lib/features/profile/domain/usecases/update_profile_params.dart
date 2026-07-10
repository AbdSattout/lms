class UpdateProfileParams {
  final String? email;
  final String? phone;
  final String? university;

  const UpdateProfileParams({
    this.email,
    this.phone,
    this.university,
  });

  Map<String, dynamic> toJson() {
    return {
      "email": email,
      "phone": phone,
      "university": university,
    };
  }
}