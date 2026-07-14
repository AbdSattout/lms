import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final int id;
  final String name;
  final String picture;
  final String idTelegram;

  const UserEntity({
    required this.id,
    required this.name,
    required this.picture,
    required this.idTelegram,
  });

  @override
  List<Object?> get props => [id, name, picture, idTelegram];
}