// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'csvFile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CSVFile _$CSVFileFromJson(Map<String, dynamic> json) => CSVFile(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      name: json['name'] as String,
      address: json['address'] as String,
      number: json['number'] as String,
    );

Map<String, dynamic> _$CSVFileToJson(CSVFile instance) => <String, dynamic>{
      'lat': instance.lat,
      'lng': instance.lng,
      'name': instance.name,
      'address': instance.address,
      'number': instance.number,
    };
