import 'package:flashlet/components/DeckCard.dart';
import 'package:flashlet/components/FlashCardItem.dart';
import 'package:flashlet/models/Deck.dart';
import 'package:flashlet/pages/CreatePage.dart';
import 'package:flashlet/repositories/DeckRepository.dart';
import 'package:flashlet/repositories/StudyRecordRepository.dart';
import 'package:flutter/material.dart';

class DeckInfoPage extends StatefulWidget {
  DeckInfoPage(this.id);

  final String id;

  @override
  _DeckInfoPageState createState() {
    return _DeckInfoPageState(id);
  }
}

class _DeckInfoPageState extends State<DeckInfoPage> {
  final DeckRepository deckRepo = DeckRepository();
  final StudyRecordRepository recordRepo = StudyRecordRepository();

  String id;
  Deck _deck;

  _DeckInfoPageState(this.id);

  Future<void> _confirmDeletion() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm deletion?'),
          content: Text(
              "Such operation is irreversible. You‘d better look before you leap"),
          actions: <Widget>[
            FlatButton(
              child: Text('REGRET'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('CONFIRM'),
              textColor: Colors.redAccent,
              onPressed: () {
                deckRepo.deleteDeckById(_deck.id);
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Deck Info"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CreatePage(
                              deck: _deck,
                            )));
              },
            ),
            IconButton(
                icon: Icon(Icons.delete), onPressed: () => _confirmDeletion())
          ],
        ),
        body: FutureBuilder(
            future: deckRepo.ready,
            builder: (BuildContext context, snapshot) {
              if (snapshot.data == null) {
                return CircularProgressIndicator();
              }

              _deck = deckRepo.getDecksById(id).first;

              return FutureBuilder(
                  future: deckRepo.ready,
                  builder: (BuildContext context, snapshot) {
                    if (snapshot.data == null) {
                      return CircularProgressIndicator();
                    }
                    return Container(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        children: <Widget>[
                          DeckCard(
                            _deck,
                            hasDescription: true,
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 8),
                          ),
                          Row(
                            children: <Widget>[
                              Text(
                                "${_deck.cards.length > 1 ? "Cards" : "Card"} (${_deck.cards.length}):",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20.0,
                                  letterSpacing: 0.15,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 8),
                          ),
                          Flexible(
                              child: _deck.cards.isEmpty
                                  ? Text(
                                      "No Card",
                                      style: TextStyle(),
                                    )
                                  : GridView.count(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 8,
                                      mainAxisSpacing: 8,
                                      children: _deck.cards
                                          .map((cardEntity) => FlashCardItem(
                                                data: cardEntity,
                                                fontSize: 20,
                                              ))
                                          .toList(),
                                    ))
                        ],
                      ),
                    );
                  });
            }));
  }
}
