import 'package:crypto/crypto.dart';
import 'dart:convert';

class Util {
    static String generateId (String stringToBeHashed) {
      print(DateTime.now().toIso8601String());
      var bytes = utf8.encode(stringToBeHashed + DateTime.now().toIso8601String());
      var digest = md5.convert(bytes);
      var base64String = base64Encode(digest.bytes);
      return base64String.substring(0, base64String.length-2);
  }
}