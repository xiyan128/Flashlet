import 'dart:io';
// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/foundation.dart' show ValueNotifier;
// import 'package:path_provider/path_provider.dart';

// import 'package:flashlet/Deck.dart';

// Repository for storing and retrieving decks in local files
class Repository {
  List<File> _files = [];

  // List<Deck> _decks;

  factory Repository() {
    final instance = Repository._internal();
    return instance;
  }

  // internal constructor
  Repository._internal() {
    this._init();
  }

  _init() async {
    try {

      // final documentDir = await getApplicationDocumentsDirectory();
      final documentDir = Directory('./');
      final path = documentDir.path;

      final deckDir = Directory('${path}deck/');

      // initialize the deck directory if it hasn't been there yet
      if (!await deckDir.exists()) await deckDir.create(recursive: true);
      
      deckDir.list().listen((FileSystemEntity entity) {
        //check if this entity is a file
        if (entity is File){
          print(entity.path);
          entity.readAsString().then((content) {
            print(content);
          });
          _files.add(entity);
        }
      });

    } on Error catch (e) {
      throw e;
    }
  }

}

main(List<String> args) {
  Repository();

}