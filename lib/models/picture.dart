import 'package:json_annotation/json_annotation.dart';
import 'package:unsplash_flutter/models/urls.dart';
import 'package:unsplash_flutter/models/user.dart';

part 'picture.g.dart';

@JsonSerializable()
class PictureModel {
  final String id;
  final Urls urls;
  final int likes;
  final User user;
  @JsonKey(name: 'blur_hash')
  final String blurHash;

  const PictureModel(
      {required this.id,
      required this.urls,
      required this.likes,
      required this.blurHash,
      required this.user});

  factory PictureModel.fromJson(Map<String, dynamic> json) =>
      _$PictureModelFromJson(json);
}
