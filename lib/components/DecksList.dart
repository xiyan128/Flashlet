import 'package:flashlet/components/DeckCard.dart';
import 'package:flashlet/models/Deck.dart';
import 'package:flashlet/pages/DeckInfoPage.dart';
import 'package:flashlet/repositories/DeckRepository.dart';
import 'package:flutter/material.dart';

class DecksList extends StatefulWidget {
  @override
  _DecksListState createState() => _DecksListState();
}

class _DecksListState extends State<DecksList> {
  final DeckRepository deckRepo = DeckRepository();

  List<Deck> decks;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: deckRepo.ready,
        builder: (BuildContext context, snapshot) {
          if (snapshot.data == null) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          decks = deckRepo.getDecks();

          return decks.isEmpty
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.folder_open,
                    size: 34,
                    color: Colors.white70,
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "No Deck Yet",
                    style: TextStyle(
                        fontSize: 20,
                        letterSpacing: 0.15,
                        color: Colors.white70,
                        height: 1.2),
                  ),
                ],
              )
            ],
          )
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            itemCount: decks.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              DeckInfoPage(decks[index].id)));
                },
                child: Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: DeckCard(decks[index]),
                ),
              );
            },
          );
        });
  }
}
