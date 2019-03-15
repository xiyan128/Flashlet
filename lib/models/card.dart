import 'package:flashlet/core/repository/CardEntity.dart';
import 'package:flashlet/core/Uuid.dart';
import 'package:meta/meta.dart';

@immutable
class Card {
  final String front;
  final String back;
  final String id;

  Card(this.front, this.back, {String id})
      : this.id = id ?? Uuid().generateV4();

  @override
  int get hashCode => front.hashCode ^ back.hashCode ^ id.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Card &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          front == other.front &&
          back == other.back;

  Card copyWith({String front, String back, String id}) =>
      Card(front ?? this.front, back ?? this.back, id: id ?? this.id);

  CardEntity toEntity() => CardEntity(this.front, this.back, this.id);

  @override
  String toString() => "Card{front: $front, back: $back, id: $id}";

  static fromEntity(CardEntity entity) =>
      Card(entity.back, entity.front, id: entity.id);
}
