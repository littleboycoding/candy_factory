import "dart:convert";

import 'package:json_annotation/json_annotation.dart';

part "metadata.g.dart";

@JsonSerializable()
class Metadata {
  const Metadata({
    required this.name,
    required this.description,
    required this.image,
  });

  final String name;
  final String description;
  final String image;

  factory Metadata.fromJson(Map<String, dynamic> json) =>
      _$MetadataFromJson(json);

  Map<String, dynamic> toJson() => _$MetadataToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
