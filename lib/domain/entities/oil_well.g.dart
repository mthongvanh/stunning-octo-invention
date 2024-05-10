// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'oil_well.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OilWell _$OilWellFromJson(Map<String, dynamic> json) => OilWell(
      identifier: json['identifier'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );

Map<String, dynamic> _$OilWellToJson(OilWell instance) => <String, dynamic>{
      'identifier': instance.identifier,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
