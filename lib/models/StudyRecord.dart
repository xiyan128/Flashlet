import 'package:json_annotation/json_annotation.dart';

part 'StudyRecord.g.dart';

// A class combining the study time and result (proficiency) of a card
@JsonSerializable(nullable: false)
class StudyRecord {
  final int proficiency;
  final DateTime datetime;

  StudyRecord({this.datetime, this.proficiency});

  @override
  String toString() {
    return '$datetime w/ $proficiency';
  }

  factory StudyRecord.fromJson(Map<String, dynamic> json) =>
      _$StudyRecordFromJson(json);

  Map<String, dynamic> toJson() => _$StudyRecordToJson(this);
}
