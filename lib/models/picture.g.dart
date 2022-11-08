// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'picture.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PictureModel _$PictureModelFromJson(Map<String, dynamic> json) => PictureModel(
      id: json['id'] as String,
      urls: Urls.fromJson(json['urls'] as Map<String, dynamic>),
      likes: json['likes'] as int,
      blurHash: json['blur_hash'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PictureModelToJson(PictureModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'urls': instance.urls,
      'likes': instance.likes,
      'user': instance.user,
      'blur_hash': instance.blurHash,
    };
