import 'package:flashlet/models/Card.dart' as FlashCard;
import 'package:flashlet/models/Deck.dart';
import 'package:flashlet/repositories/DeckRepository.dart';
import 'package:flashlet/repositories/StudyRecordRepository.dart';
import 'package:flutter/material.dart';

class CreatePage extends StatefulWidget {
  CreatePage({this.deck});

  final Deck deck;

  @override
  _CreatePageState createState() => deck == null
      ? _CreatePageState()
      : _CreatePageState.edit(previousDeck: deck);
}

class _CreatePageState extends State<CreatePage> {
  final DeckRepository deckRepo = DeckRepository();
  final StudyRecordRepository recordRepo = StudyRecordRepository();
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  GlobalKey<FormState> _cardFormKey = new GlobalKey<FormState>();

//  List<FlashCard.Card> newCards;
//  String title;
//  String description;
  String tempCardFront;
  String tempCardBack;
  String barTitle;

  Deck deck;

  _CreatePageState() {
    deck = Deck(title: "", description: "", cards: []);
    barTitle = "Create a new deck";
  }

  _CreatePageState.edit({Deck previousDeck}) {
    deck = previousDeck;
    barTitle = "Edit a deck";
  }

  @override
  Widget build(BuildContext buildContext) => Scaffold(
      appBar: AppBar(
        title: Text(barTitle),
        centerTitle: false,
//        leading: Icon(Icons.close),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_formKey.currentState.validate() && deck.cards.isNotEmpty) {
            _formKey.currentState.save();
            deckRepo.setDeck(deck);
            _formKey.currentState.reset();
            _cardFormKey.currentState.reset();
            Navigator.pop(buildContext);
          }
        },
        child: Icon(Icons.save),
      ),
      body: FutureBuilder(
          future: deckRepo.ready,
          builder: (BuildContext context, snapshot) {
            return FutureBuilder(
                future: deckRepo.ready,
                builder: (BuildContext context, snapshot) {
                  if (snapshot.data == null) {
                    return CircularProgressIndicator();
                  }

                  return Container(
                      padding: EdgeInsets.all(16),
                      child: Form(
                          key: _formKey,
                          child: ListView(children: <Widget>[
                            Row(
                              children: <Widget>[
                                Text(
                                  "Deck Info",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 20.0,
                                      letterSpacing: 0.15,
                                      height: 1.12),
                                ),
                              ],
                            ),
                            TextFormField(
                                decoration: InputDecoration(
                                    labelText: "Title",
                                    icon: Icon(Icons.title)),
                                initialValue: deck.title,
                                onSaved: (str) => this.deck.title = str,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter some text';
                                  }
                                }),
                            TextFormField(
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                initialValue: deck.description,
                                decoration: InputDecoration(
                                    labelText: "Description",
                                    icon: Icon(Icons.description)),
                                onSaved: (str) => this.deck.description = str,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter some text';
                                  }
                                }),
                            Padding(
                              padding: EdgeInsets.only(top: 16.0),
                              child: Divider(),
                            ),
                            Form(
                              key: _cardFormKey,
                              child: Column(children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Text(
                                      "Cards",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 20.0,
                                          letterSpacing: 0.15,
                                          height: 1.12),
                                    ),
                                  ],
                                ),
                                TextFormField(
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                      labelText: "Front Side",
                                      icon: Icon(Icons.filter_1)),
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please enter some text';
                                    }
                                  },
                                  onSaved: (str) => this.tempCardFront = str,
                                ),
                                TextFormField(
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 3,
                                  decoration: InputDecoration(
                                      labelText: "Back Side",
                                      icon: Icon(Icons.filter_2)),
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please enter some text';
                                    }
                                  },
                                  onSaved: (str) => this.tempCardBack = str,
                                ),
                                Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: RaisedButton.icon(
                                      label: Text(
                                        "SUBMIT CARD",
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 1.25),
                                      ),
                                      icon: Icon(Icons.add),
                                      onPressed: () {
                                        if (_cardFormKey.currentState
                                            .validate()) {
                                          _cardFormKey.currentState.save();
                                          setState(() {
                                            deck.cards.add(FlashCard.Card(
                                                front: tempCardFront,
                                                back: tempCardBack));
                                            _cardFormKey.currentState.reset();
                                          });
                                        }
                                      },
                                    ))
                              ]),
                            ),
                            Divider(),
                            deck.cards.isEmpty
                                ? Text(
                                    "No Card Yet",
                                    style: TextStyle(),
                                  )
                                : Column(
                                    children: deck.cards
                                        .map(
                                          (card) => Dismissible(
                                                key: Key(card.id),
                                                child: ListTile(
                                                  contentPadding:
                                                      EdgeInsets.all(0),
                                                  title: Text(card.front),
                                                  subtitle: Text(card.back),
                                                ),
                                                direction:
                                                    DismissDirection.startToEnd,
                                                onDismissed: (direction) {
                                                  // Remove the item from our data source.
                                                  setState(() {
                                                      deck.cards.remove(card);
                                                  });

                                                  recordRepo.deleteAllRecordsByID(card.id);
                                                  // Then show a snackbar!
                                                },
                                              ),
                                        )
                                        .toList(),
                                  )    //    )
                          ])));
                });
          }));
}
