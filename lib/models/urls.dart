import 'package:json_annotation/json_annotation.dart';

part 'urls.g.dart';

@JsonSerializable()
class Urls {
  final String raw;
  final String full;
  final String regular;
  final String small;
  final String thumb;
  @JsonKey(name: 'small_s3')
  final String smallS3;

  const Urls({
    required this.raw,
    required this.full,
    required this.regular,
    required this.small,
    required this.thumb,
    required this.smallS3,
  });
  factory Urls.fromJson(Map<String, dynamic> json) => _$UrlsFromJson(json);
}
