import 'package:flashlet/Card.dart';
import 'package:flashlet/Util.dart';

class Deck {

  String id;
  String title;
  String description;

  List<Card> cards;

  Deck({this.title, this.description, this.cards}) {
    // The ID of the deck is the base64 encoded md5 value of deck's title + description[0:8]
    this.id = Util.generateId(this.title + (this.description.length > 8 ? this.description.substring(0,8) : this.description));
  }

  int get length {
    return cards.length;
  }

  @override
  String toString() {
    // TODO: implement toString
    return 'Deck@${this.id}: { title: \"${this.title}\", description: \"${this.description}\", cards: ${this.cards}}';
  }
}