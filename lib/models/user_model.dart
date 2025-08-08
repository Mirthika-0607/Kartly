import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class User {
  String? name;
  String? phoneNumber;
  String? email;
  String? address;
  DateTime? createdAt;

  User({
    this.name,
    this.phoneNumber,
    this.email,
    this.address,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}