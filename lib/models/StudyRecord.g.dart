// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'StudyRecord.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudyRecord _$StudyRecordFromJson(Map<String, dynamic> json) {
  return StudyRecord(
      datetime: DateTime.parse(json['datetime'] as String),
      proficiency: json['proficiency'] as int);
}

Map<String, dynamic> _$StudyRecordToJson(StudyRecord instance) =>
    <String, dynamic>{
      'proficiency': instance.proficiency,
      'datetime': instance.datetime.toIso8601String()
    };
