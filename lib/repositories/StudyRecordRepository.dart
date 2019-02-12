import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flashlet/models/StudyRecord.dart';
import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:path_provider/path_provider.dart';

/// Creates instance of a study record repository. Key is used as a filename
class StudyRecordRepository {
  static final Map<String, StudyRecordRepository> _cache = new Map();

  String _filename;
  File _file;
  Map<String, List<StudyRecord>> _data;

  /// [ValueNotifier] which notifies about errors during storage initialization
  ValueNotifier<Error> onError;

  /// A future indicating if StudyRecord Repository instance is ready for read/write operations
  Future<bool> ready;

  factory StudyRecordRepository({String key: "studyRecordBank"}) {
    if (_cache.containsKey(key)) {
      return _cache[key];
    } else {
      final instance = StudyRecordRepository._internal(key);
      _cache[key] = instance;

      return instance;
    }
  }

  StudyRecordRepository._internal(String key) {
    _filename = key;
    _data = {};
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
          _data = Map<String, List<dynamic>>.from(jsonContent).map(
              (id, recordMapList) => MapEntry(
                  id,
                  recordMapList
                      .map((recordMap) => StudyRecord.fromJson(recordMap))
                      .toList()));
        } catch (err) {
          onError.value = err;
          print(err);
          _data = {};
          _file.writeAsStringSync('{}');
        }
      } else {
        // if such file doesn't exist, repeat _init since now it should be created
        _file.writeAsStringSync('{}');
        return _init();
      }
    } on Error catch (err) {
      onError.value = err;
    }
  }

  /// Saves or Update a studyRecord
  setRecord(String id, StudyRecord record) {
    if (_data.containsKey(id)) {
      // if _data already contains that card's record, add the new record to it;
      _data[id].add(record);
      // sort it in chronological order
      _data[id].sort((a, b) => a.datetime.compareTo(b.datetime));
    } else {
      //  otherwise create a new record list for this ID.
      _data[id] = [record];
    }

    return _flush();
  }

  // delete all records of a card if it has
  deleteAllRecordsByID(String id) {
    if (_data.containsKey(id)) _data.remove(id);
    return _flush();
  }

  Map<String, List<StudyRecord>> getAllRecords() {
    return _data ?? {};
  }

  List<StudyRecord> getRecordById(String id) {
    return _data[id] ?? [];
  }

  /// store [_data] to the disk
  _flush() {
    final serialized = json.encode(_data.map((id, recordList) =>
        MapEntry(id, recordList.map((record) => record.toJson()).toList())));
    _file.writeAsStringSync(serialized);
  }
}
