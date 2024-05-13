import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'oil_well.g.dart';

@JsonSerializable()
class OilWell {
  final String identifier;
  final double latitude;
  final double longitude;

  OilWell({
    required this.identifier,
    required this.latitude,
    required this.longitude,
  });

  static OilWell fromJson(final Map<String, dynamic> json) => _$OilWellFromJson(json);

  Map<String, dynamic> toJson() => _$OilWellToJson(this);
}
