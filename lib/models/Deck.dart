import 'package:flashlet/Util.dart';
import 'package:flashlet/models/Card.dart';

class Deck {
  String id;
  String title;
  String description;

  List<Card> cards;

  Deck({this.title, this.description, this.cards}) {
    // The ID of the deck is the base64 encoded md5 value of deck's title + description
    this.id = Util.generateId(this.title + this.description);
  }

  Deck.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];

    try {
      // for each card in the json['cards'], turn it into a JSON; then return the whole list
      cards =
          (json['cards'] as List).map((card) => Card.fromJson(card)).toList();
    } on FormatException {
      // rethrow if it contains a deformed card
      rethrow;
    }

    // null check
    if (id == null || title == null || description == null)
      throw FormatException("Cannot parse a deformed Deck");
  }

  int get length {
    return cards.length;
  }

  @override
  String toString() {
    return 'Deck@${this.id}: { title: \"${this.title}\", description: \"${this.description}\", cards: ${this.cards}}';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'cards': cards.map((card) => card.toJson()).toList()
      };
}
