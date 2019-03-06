import 'package:flashlet/components/FlashCard.dart';
import 'package:flashlet/models/Deck.dart';
import 'package:flashlet/models/StudyRecord.dart';
import 'package:flashlet/repositories/StudyRecordRepository.dart';
import 'package:flutter/material.dart';

class StudyPage extends StatefulWidget {
  StudyPage({@required this.deck, Key key}):super(key: key);

  final Deck deck;

  @override
  _StudyPageState createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> {

  final StudyRecordRepository recordRepo = StudyRecordRepository();

  int currentIndex = 0;
  int currentProficiency = 0;

  setProficiency(int proficiency) {
    setState(() {
      currentProficiency = proficiency;
    });
  }

  Color getColorByProficiency(int proficiency) {
    switch (proficiency) {
      case 1:
        return Colors.redAccent;
      case 2:
        return Colors.orangeAccent;
      case 3:
        return Colors.yellowAccent;
      case 4:
        return Colors.lightGreen;
      case 5:
        return Colors.lightGreenAccent;
    }
    return null;
  }

  saveCurrentProficiency() {
    recordRepo.setRecord(widget.deck.cards[currentIndex].id,
        StudyRecord(datetime: DateTime.now(), proficiency: currentProficiency));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Study (${currentIndex + 1}/${widget.deck.cards.length})"),
          centerTitle: false,
        ),
        floatingActionButton: currentProficiency != 0
            ? FloatingActionButton(
                onPressed: () {
                  saveCurrentProficiency();
                  if (currentIndex == widget.deck.cards.length - 1) {
                    Navigator.pop(context);
                    return;
                  }
                  setState(() {
                    currentProficiency = 0;
                    currentIndex++;
                  });
                },
                child: Icon(
                  currentIndex == widget.deck.cards.length - 1
                      ? Icons.done_all
                      : Icons.skip_next,
                ),
                backgroundColor: getColorByProficiency(currentProficiency),
              )
            : null,
        body: FutureBuilder(
            future: recordRepo.ready,
            builder: (BuildContext context, snapshot) {
              return Container(
                padding: EdgeInsets.all(8),
                child: FlashCard(data: widget.deck.cards[currentIndex]),
              );
            }),
        bottomNavigationBar: BottomAppBar(
            child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.exposure_neg_2),
                onPressed: () => setProficiency(1),
                color: Colors.redAccent,
              ),
              IconButton(
                icon: Icon(Icons.exposure_neg_1),
                onPressed: () => setProficiency(2),
                color: Colors.orangeAccent,
              ),
              IconButton(
                icon: Icon(Icons.exposure_zero),
                onPressed: () => setProficiency(3),
                color: Colors.yellowAccent,
              ),
              IconButton(
                icon: Icon(Icons.exposure_plus_1),
                onPressed: () => setProficiency(4),
                color: Colors.lightGreen,
              ),
              IconButton(
                icon: Icon(Icons.exposure_plus_2),
                onPressed: () => setProficiency(5),
                color: Colors.lightGreenAccent,
              ),
            ],
          ),
        )));
  }
}
