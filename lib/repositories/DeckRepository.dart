import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flashlet/models/Deck.dart';
import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:path_provider/path_provider.dart';

/// Creates instance of a deck repository. Key is used as a filename
class DeckRepository {
  static final Map<String, DeckRepository> _cache = new Map();

  String _filename;
  File _file;
  List<Deck> _data;

  /// [ValueNotifier] which notifies about errors during storage initialization
  ValueNotifier<Error> onError;

  /// A future indicating if DeckRepository instance is ready for read/write operations
  Future<bool> ready;

  factory DeckRepository({String key: "deckBank"}) {
    if (_cache.containsKey(key)) {
      return _cache[key];
    } else {
      final instance = DeckRepository._internal(key);
      _cache[key] = instance;

      return instance;
    }
  }

  DeckRepository._internal(String key) {
    _filename = key;
    _data = [];
    onError = new ValueNotifier(null);

    ready = new Future<bool>(() async {
      try {
        await this._init();
      } catch (e) {
        return false;
      }
      return true;
    });
  }

  _init() async {
    try {
      // get the application doc dir, for both Android and iOS
      final documentDir = await getApplicationDocumentsDirectory();
//      final documentDir = Directory(".");
      final path = documentDir.path;

      _file = File('$path/$_filename.json');

      var exists = _file.existsSync();

      if (exists) {
        // read content if such file exist.
        final content = await _file.readAsString();
        try {
          // decode a json (may throw an exception)
          final jsonContent = json.decode(content);
          _data =
              (jsonContent as List).map((deck) => Deck.fromJson(deck)).toList();
        } catch (err) {
          onError.value = err;
          _data = [];
          _file.writeAsStringSync('[]');
        }
      } else {
        // if such file doesn't exist, repeat _init since now it should be created
        _file.writeAsStringSync('[]');
        return _init();
      }
    } on Error catch (err) {
      onError.value = err;
    }
  }

  /// Saves or Update a deck (depending on the ID's duplicity ).
  setDeck(Deck deck) async {
    int oldDeckIndex =
        _data.indexWhere((deckToBeChecked) => deck.id == deckToBeChecked.id);

    if (oldDeckIndex >= 0) {
      _data[oldDeckIndex] = deck;
    } else {
      _data.add(deck);
    }

    return _flush();
  }

  Future<Deck> deleteDeckById(String id) async {
    int deletingDeckIndex =
        _data.indexWhere((deckToBeChecked) => id == deckToBeChecked.id);
    var deletedDeck = _data.removeAt(deletingDeckIndex);
    return Future<Deck>(() {
      _flush();
      return deletedDeck;
    });
  }

  // Three ways to get decks:
  // 1.get all decks
  List<Deck> getDecks() {
    return _data;
  }

  // 2.get decks by title name
  // there may be decks with identical titles, so it returns List<Deck>
  List<Deck> getDecksByTitle(String title) {
    return _data.where((deck) => deck.title == title);
  }

  // 3.get decks by ID
  // there may be decks with identical ID, so it still returns List<Deck>
  List<Deck> getDecksById(String id) {
    return _data.where((deck) => deck.id == id).toList();
  }

  /// store [_data] to the disk
  _flush() async {
    final serialized = json.encode(_data.map((deck) => deck.toJson()).toList());
    _file.writeAsStringSync(serialized);
  }
}
