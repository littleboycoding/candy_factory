import 'package:json_annotation/json_annotation.dart';

part "exported.g.dart";

@JsonSerializable()
class Exported {
  const Exported({required this.id, required this.uris});

  final int id;
  final String uris;

  factory Exported.fromJson(Map<String, dynamic> json) =>
      _$ExportedFromJson(json);

  Map<String, dynamic> toJson() => _$ExportedToJson(this);
}
