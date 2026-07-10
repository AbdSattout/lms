class UserPictureModel {
  final int id;
  final String name;
  final String picture;

  UserPictureModel({
    required this.id,
    required this.name,
    required this.picture,
  });

  factory UserPictureModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return UserPictureModel(
      id: json["id"],
      name: json["name"],
      picture: json["picture"] ?? "",
    );
  }
}