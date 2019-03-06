import 'package:flashlet/Retention.dart';
import 'package:flashlet/models/Deck.dart';
import 'package:flashlet/pages/StudyPage.dart';
import 'package:flashlet/repositories/StudyRecordRepository.dart';
import 'package:flutter/material.dart';

class DeckCard extends StatelessWidget {
  DeckCard(this._deck, {this.hasDescription: false});

  final Deck _deck;
  final bool hasDescription;
  final StudyRecordRepository recordRepo = StudyRecordRepository();

  Deck sortDeckByCardsByRecallRates(Deck deckToBeSorted) {
    deckToBeSorted.cards.sort((a,b) => Retention.getCurrentRecallRate(recordRepo.getRecordById(a.id)).compareTo(Retention.getCurrentRecallRate(recordRepo.getRecordById(a.id))));
    return deckToBeSorted;
  } 

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: recordRepo.ready,
        builder: (BuildContext context, snapshot) {
          final records =
              _deck.cards.map((card) => recordRepo.getRecordById(card.id));

          final recallRates =
              records.map((record) => Retention.getCurrentRecallRate(record));

          final goodCards =
              recallRates.where((recallRates) => recallRates >= 0.665);
          final mediumCards = recallRates.where(
              (recallRates) => recallRates <= 0.664 && recallRates >= 0.335);
          final badCards =
              recallRates.where((recallRates) => recallRates <= 0.334);
          final double meanRecallRate =
              recallRates.fold(0, (a, b) => a + b) / (recallRates.length == 0 ? 1e-10 : recallRates.length);

          String recallIndicatorText =
              (meanRecallRate * 100).truncate().toString();
          Color recallIndicatorColor;

          if (meanRecallRate >= 0.665) {
            recallIndicatorText += "/100: MASTERED";
            recallIndicatorColor = Colors.lightGreenAccent;
          } else if (meanRecallRate >= 0.335) {
            recallIndicatorText += "/100: MEDIUM";
            recallIndicatorColor = Colors.yellowAccent;
          } else {
            recallIndicatorText += "/100: UNSAFE";
            recallIndicatorColor = Colors.redAccent;
          }

          return Center(
            child: Card(
              margin: EdgeInsets.all(0),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Text(
                                recallIndicatorText,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 10.0,
                                    letterSpacing: 0.5,
                                    color: recallIndicatorColor),
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  _deck.title,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 24.0,
                                      letterSpacing: 0.0,
                                      height: 1.12),
                                ),
                              ),
                            ],
                          ),
                          hasDescription
                              ? Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          _deck.description,
                                          maxLines: 3,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              fontSize: 14.0,
                                              letterSpacing: 0.25),
                                        ),
                                      )
                                    ],
                                  ))
                              : null,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Text(
                                    goodCards.length.toString() + "   ",
                                    style: TextStyle(
                                        color: Colors.lightGreenAccent,
                                        fontSize: 20,
                                        letterSpacing: 0.15,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    mediumCards.length.toString() + "   ",
                                    style: TextStyle(
                                        color: Colors.yellowAccent,
                                        fontSize: 20,
                                        letterSpacing: 0.15,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    badCards.length.toString() + "   ",
                                    style: TextStyle(
                                        color: Colors.redAccent,
                                        fontSize: 20,
                                        letterSpacing: 0.15,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: Icon(Icons.arrow_forward),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              StudyPage(deck: sortDeckByCardsByRecallRates(_deck))));
                                },
                              ),
                            ],
                          ),
                        ].where((Object o) => o != null).toList(),
                      ),
                    ),
                  ]),
            ),
          );
        });
  }
}
