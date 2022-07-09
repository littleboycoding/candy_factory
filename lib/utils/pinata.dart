import 'dart:convert';
import 'dart:typed_data';

import "package:http/http.dart" as http;
import 'package:json_annotation/json_annotation.dart';

import '../../models/metadata.dart';

part "pinata.g.dart";

@JsonSerializable()
class PinataOption {
  const PinataOption({
    this.cidVersion,
  });

  final int? cidVersion;

  factory PinataOption.fromJson(Map<String, dynamic> json) =>
      _$PinataOptionFromJson(json);

  Map<String, dynamic> toJson() => _$PinataOptionToJson(this);
}

@JsonSerializable()
class PinataMetadata {
  const PinataMetadata({
    this.name,
    this.keyvalues,
  });

  final String? name;
  final Map<String, String>? keyvalues;

  factory PinataMetadata.fromJson(Map<String, dynamic> json) =>
      _$PinataMetadataFromJson(json);

  Map<String, dynamic> toJson() => _$PinataMetadataToJson(this);
}

@JsonSerializable()
class PinataContent {
  const PinataContent({
    required this.content,
  });

  final dynamic content;

  factory PinataContent.fromJson(Map<String, dynamic> json) =>
      _$PinataContentFromJson(json);

  Map<String, dynamic> toJson() => _$PinataContentToJson(this);
}

@JsonSerializable()
class PinJSONToIPFSBody {
  const PinJSONToIPFSBody({
    this.pinataOptions,
    this.pinataMetadata,
    required this.pinataContent,
  });

  final PinataOption? pinataOptions;
  final PinataMetadata? pinataMetadata;
  final dynamic pinataContent;

  factory PinJSONToIPFSBody.fromJson(Map<String, dynamic> json) =>
      _$PinJSONToIPFSBodyFromJson(json);

  Map<String, dynamic> toJson() => _$PinJSONToIPFSBodyToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class PinResponse {
  const PinResponse({
    required this.ipfsHash,
    required this.pinSize,
    required this.timestamp,
    this.isDuplicate,
  });

  final String ipfsHash;
  final int pinSize;
  final String timestamp;
  @JsonKey(name: "isDuplicate")
  final bool? isDuplicate;

  factory PinResponse.fromJson(Map<String, dynamic> json) =>
      _$PinResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PinResponseToJson(this);
}

class PinError extends Error {
  PinError(this.message);

  final String message;
}

class Pinata {
  Pinata({required this.jwt});

  final String jwt;
  final _client = http.Client();

  static final apiUri = Uri.parse("https://api.pinata.cloud");

  Map<String, String> get header => {
        "Authorization": "Bearer $jwt",
      };

  void close() {
    _client.close();
  }

  Future<PinResponse> pinFileToIPFS(Uint8List file, String name) async {
    final uri = apiUri.resolve("/pinning/pinFileToIPFS");

    final req = http.MultipartRequest("POST", uri)
      ..headers.addAll(header)
      ..fields["pinataMetadata"] = jsonEncode(
        PinataMetadata(name: name),
      )
      ..files.add(
        http.MultipartFile.fromBytes("file", file, filename: name),
      );

    final res = await _client.send(req);

    if (res.statusCode != 200) {
      final raw = await res.stream.bytesToString();
      throw PinError(
        jsonDecode(raw)["error"]["reason"],
      );
    }

    final json = await res.stream.bytesToString().then(jsonDecode);
    final pinResponse = PinResponse.fromJson(json);

    return pinResponse;
  }

  Future<PinResponse> pinJSONToIPFS(Metadata metadata, String name) async {
    final uri = apiUri.resolve("/pinning/pinJSONToIPFS");

    final header = this.header..["Content-Type"] = "application/json";
    final body = PinJSONToIPFSBody(
      pinataContent: metadata,
      pinataMetadata: PinataMetadata(
        name: name,
      ),
    );

    final res = await _client.post(
      uri,
      headers: header,
      body: jsonEncode(body),
    );

    if (res.statusCode != 200) {
      final raw = res.body;
      throw PinError(
        jsonDecode(raw)["error"]["reason"],
      );
    }

    final json = jsonDecode(res.body);
    final pinResponse = PinResponse.fromJson(json);

    return pinResponse;
  }
}
