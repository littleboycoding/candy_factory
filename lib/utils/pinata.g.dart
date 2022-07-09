// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pinata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PinataOption _$PinataOptionFromJson(Map<String, dynamic> json) => PinataOption(
      cidVersion: json['cidVersion'] as int?,
    );

Map<String, dynamic> _$PinataOptionToJson(PinataOption instance) =>
    <String, dynamic>{
      'cidVersion': instance.cidVersion,
    };

PinataMetadata _$PinataMetadataFromJson(Map<String, dynamic> json) =>
    PinataMetadata(
      name: json['name'] as String?,
      keyvalues: (json['keyvalues'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
    );

Map<String, dynamic> _$PinataMetadataToJson(PinataMetadata instance) =>
    <String, dynamic>{
      'name': instance.name,
      'keyvalues': instance.keyvalues,
    };

PinataContent _$PinataContentFromJson(Map<String, dynamic> json) =>
    PinataContent(
      content: json['content'],
    );

Map<String, dynamic> _$PinataContentToJson(PinataContent instance) =>
    <String, dynamic>{
      'content': instance.content,
    };

PinJSONToIPFSBody _$PinJSONToIPFSBodyFromJson(Map<String, dynamic> json) =>
    PinJSONToIPFSBody(
      pinataOptions: json['pinataOptions'] == null
          ? null
          : PinataOption.fromJson(
              json['pinataOptions'] as Map<String, dynamic>),
      pinataMetadata: json['pinataMetadata'] == null
          ? null
          : PinataMetadata.fromJson(
              json['pinataMetadata'] as Map<String, dynamic>),
      pinataContent: json['pinataContent'],
    );

Map<String, dynamic> _$PinJSONToIPFSBodyToJson(PinJSONToIPFSBody instance) =>
    <String, dynamic>{
      'pinataOptions': instance.pinataOptions,
      'pinataMetadata': instance.pinataMetadata,
      'pinataContent': instance.pinataContent,
    };

PinResponse _$PinResponseFromJson(Map<String, dynamic> json) => PinResponse(
      ipfsHash: json['IpfsHash'] as String,
      pinSize: json['PinSize'] as int,
      timestamp: json['Timestamp'] as String,
      isDuplicate: json['isDuplicate'] as bool?,
    );

Map<String, dynamic> _$PinResponseToJson(PinResponse instance) =>
    <String, dynamic>{
      'IpfsHash': instance.ipfsHash,
      'PinSize': instance.pinSize,
      'Timestamp': instance.timestamp,
      'isDuplicate': instance.isDuplicate,
    };
