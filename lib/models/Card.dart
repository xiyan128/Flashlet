import 'package:flashlet/Util.dart';

class Card {
  String front;
  String back;
  String id;

  Card({this.front, this.back}) {
    // The ID of the card is the base64 encoded md5 value of card's front + back
    this.id = Util.generateId(this.front + this.back);
  }

  Card.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    front = json['front'];
    back = json['back'];
    if (id == null || front == null || back == null)
      throw FormatException("Cannot parse a deformed card");
  }

  @override
  String toString() {
    return 'Card@${this.id}: { front: \"${this.front}\", back: \"${this.back}\" }';
  }

  Map<String, dynamic> toJson() => {'id': id, 'front': front, 'back': back};
}
