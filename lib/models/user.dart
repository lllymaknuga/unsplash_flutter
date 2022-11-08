import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';
@JsonSerializable()
class User {
  final String id;
  final String? username;
  @JsonKey(name: 'first_name')
  final String? firstName;
  @JsonKey(name: 'last_name')
  final String? lastName;

  const User({required this.id, this.username, this.firstName, this.lastName});

  factory User.fromJson(Map<String, dynamic> json) =>
      _$UserFromJson(json);
}