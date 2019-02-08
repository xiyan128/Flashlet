import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';
import 'package:flashlet/Util.dart';

class Card {
  String front;
  String back;
  String id;
  
  Card({this.front, this.back}) {
    // The ID of the card is the base64 encoded md5 value of card's front + back[0:5]
    this.id = Util.generateId(this.front + (this.back.length > 5 ? this.back.substring(0,5) : this.back));
  }

  @override
  String toString() {
    return 'Card@${this.id}: { front: \"${this.front}\", back: \"${this.back}\" }';
  }
}
