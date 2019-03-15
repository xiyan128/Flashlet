import 'package:flashlet/core/repository/DeckEntity.dart';
import 'package:flashlet/core/Uuid.dart';
import 'package:flashlet/models/Card.dart';
import 'package:meta/meta.dart';

@immutable
class Deck {
  final String id;
  final String title;
  final String description;
  final List<Card> cards;

  Deck(this.title, this.description, this.cards, {String id})
      : this.id = id ?? Uuid().generateV4();

  @override
  int get hashCode =>
      id.hashCode ^ title.hashCode ^ description.hashCode ^ cards.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Deck &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          description == other.description &&
          cards == other.cards;

  DeckEntity toEntity() => DeckEntity(this.id, this.title, this.description,
      this.cards.map((c) => c.toEntity()));

  @override
  String toString() =>
      "Deck{id: $id, title: $title, description: $description, cards: $cards}";

  static fromEntity(DeckEntity entity) => Deck(entity.title, entity.description,
      entity.cards.map((c) => Card.fromEntity(c)),
      id: entity.id);
}
