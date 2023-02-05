// ignore_for_file: depend_on_referenced_packages

import 'package:json_annotation/json_annotation.dart';
part 'csvFile.g.dart';

// g.dart file generator : flutter pub run build_runner build

@JsonSerializable()
class CSVFile {
  double lat;
  double lng;

  String name;
  String address;
  String number;

  CSVFile(
      {required this.lat,
      required this.lng,
      required this.name,
      required this.address,
      required this.number});

  factory CSVFile.fromJson(Map<String, dynamic> json) =>
      _$CSVFileFromJson(json);
  Map<String, dynamic> toJson() => _$CSVFileToJson(this);
}
