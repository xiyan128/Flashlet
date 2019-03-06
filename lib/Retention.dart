import 'dart:math';

import 'package:flashlet/models/StudyRecord.dart';

//import 'package:flashlet/repositories/StudyRecordRepository.dart';

class Retention {
  static final Map<int, double> proficiencyToDifficultyMap = {
    5: 2.6741789373e-7,
    4: 1.146076687e-6,
    3: 8.022536812e-6,
    2: 0.0001925408835,
    1: 0.0005776226505,
  };

  // get the current probability of correctly recalling a card from its study record
  static double getCurrentRecallRate(List<StudyRecord> recordList) {
    if (recordList == null || recordList.isEmpty) return 0;

    // if the record list is empty, the difficult is 3.0 as a default value
    // else, the difficulty is the average difficulty ( the average difficulty mapped difficulty from all records' proficiencies)
    double difficulty = recordList
            .map((record) => proficiencyToDifficultyMap[record.proficiency])
            .fold(0, (temp, current) => temp + current) /
        recordList.length;

    int numRepetitions = recordList.length;

    // duration from now, in seconds, to the last study record
    int lagTime = DateTime.now().difference(recordList.last.datetime).inSeconds;
//    int lagTime = Duration(hours: 3).inSeconds;

    return exp(-(difficulty * lagTime) / numRepetitions);
  }

  
}
