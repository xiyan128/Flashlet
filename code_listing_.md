# Create Task: Code
  
  
### Source Code Structure
  
```
D:\DEVELOPMENT\FLASHLET\LIB
│  main.dart
│  Retention.dart
│  Util.dart
│
├─components
│      DeckCard.dart
│      DecksList.dart
│      FlashCard.dart
│      FlashCardItem.dart
│      MarqueeWidget.dart
│
├─models
│      Card.dart
│      Deck.dart
│      StudyRecord.dart
│      StudyRecord.g.dart
│
├─pages
│      CreatePage.dart
│      DeckInfoPage.dart
│      HomePage.dart
│      StudyPage.dart
│
└─repositories
        DeckRepository.dart
        StudyRecordRepository.dart
```
  
### main.dart
  
```dart
import 'package:flashlet/pages/CreatePage.dart';
import 'package:flashlet/pages/HomePage.dart';
import 'package:flutter/material.dart';
  
void main() {
  runApp(new MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: new ThemeData(
      // Define the default Brightness and Colors
      brightness: Brightness.dark,
    ),
    title: "Flashlet",
    initialRoute: '/',
    routes: {
      '/': (context) => HomePage(),
      '/create': (context) => CreatePage(),
    },
  ));
}
  
```  
  
### Retention.dart
  
```dart
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
  
```  
  
### Util.dart
  
```dart
import 'dart:convert';
  
import 'package:crypto/crypto.dart';
  
class Util {
    static String generateId (String stringToBeHashed) {
      var bytes = utf8.encode(stringToBeHashed + DateTime.now().toIso8601String());
      var digest = md5.convert(bytes);
      var base64String = base64Encode(digest.bytes);
      return base64String.substring(0, base64String.length-2);
  }
}
```  
  
### DeckCard.dart.dart
  
```dart
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
  
```  
  
### DecksList.dart
  
```dart
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
  
```  
  
### FlashCard.dart
  
```dart
import 'package:flashlet/models/Card.dart' as FCard;
import 'package:flutter/material.dart';
  
class FlashCard extends StatefulWidget {
  final FCard.Card data;
  final double fontSize;
  
  const FlashCard({
    @required this.data,
    this.fontSize: 24,
    Key key,
  }) : super(key: key);
  
  @override
  State<FlashCard> createState() => _FlashCardState();
}
  
class _FlashCardState extends State<FlashCard> {
  bool _turnFront = true;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _turnFront = !_turnFront;
        });
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          color: _turnFront ? Theme.of(context).primaryColor : Colors.blue[800],
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(8),
                child: Text(
              _turnFront ? widget.data.front : widget.data.back,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: this.widget.fontSize,
              ),
            )),
          ),
        ),
      ),
    );
  }
}
  
```  
  
### FlashCardItem.dart
  
```dart
import 'package:flashlet/components/MarqueeWidget.dart';
import 'package:flashlet/models/Card.dart' as FlashCard;
import 'package:flutter/material.dart';
  
class FlashCardItem extends StatefulWidget {
  final FlashCard.Card data;
  final double fontSize;
  
  const FlashCardItem({
    @required this.data,
    this.fontSize: 24,
    Key key,
  }) : super(key: key);
  
  @override
  State<FlashCardItem> createState() => _FlashCardItemState();
}
  
class _FlashCardItemState extends State<FlashCardItem> {
  bool _turnFront = true;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _turnFront = !_turnFront;
        });
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          color: _turnFront ? Theme.of(context).primaryColor : Colors.blue[800],
          child: Center(
            child: MarqueeWidget(
                child: Text(
              _turnFront ? widget.data.front : widget.data.back,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: this.widget.fontSize,
              ),
            )),
          ),
        ),
      ),
    );
  }
}
  
```  
  
### MarqueeWidget.dart
  
```dart
// not original: credited with https://cloud.tencent.com/developer/ask/155300
import 'package:flutter/material.dart';
  
class MarqueeWidget extends StatefulWidget {
  final Widget child;
  final Axis direction;
  final Duration animationDuration, backDuration, pauseDuration;
  
  MarqueeWidget({
    @required this.child,
    this.direction: Axis.vertical,
    this.animationDuration: const Duration(milliseconds: 3000),
    this.backDuration: const Duration(milliseconds: 800),
    this.pauseDuration: const Duration(milliseconds: 800),
  });
  
  @override
  _MarqueeWidgetState createState() => _MarqueeWidgetState();
}
  
class _MarqueeWidgetState extends State<MarqueeWidget> {
  ScrollController scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    scroll();
  }
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: widget.child,
      scrollDirection: widget.direction,
      controller: scrollController,
    );
  }
  
  void scroll() async {
    while (true) {
      try {
        await Future.delayed(widget.pauseDuration);
        await scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: widget.animationDuration,
            curve: Curves.easeIn);
        await Future.delayed(widget.pauseDuration);
        await scrollController.animateTo(0.0,
            duration: widget.backDuration, curve: Curves.easeOut);
      } catch (e) {}
    }
  }
}
  
```  
  
### Card.dart
  
```dart
import 'package:flashlet/Util.dart';
  
class Card {
  String front;
  String back;
  String id;
  
  Card({this.front, this.back}) {
    // The ID of the card is the base64 encoded md5 value of card's front + back
    this.id = Util.generateId(this.front + this.back);
  }
  
  Card.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    front = json['front'];
    back = json['back'];
    if (id == null || front == null || back == null)
      throw FormatException("Cannot parse a deformed card");
  }
  
  @override
  String toString() {
    return 'Card@${this.id}: { front: \"${this.front}\", back: \"${this.back}\" }';
  }
  
  Map<String, dynamic> toJson() => {'id': id, 'front': front, 'back': back};
}
  
```  
  
### Deck.dart
  
```dart
import 'package:flashlet/Util.dart';
import 'package:flashlet/models/Card.dart';
  
class Deck {
  String id;
  String title;
  String description;
  
  List<Card> cards;
  
  Deck({this.title, this.description, this.cards}) {
    // The ID of the deck is the base64 encoded md5 value of deck's title + description
    this.id = Util.generateId(this.title + this.description);
  }
  
  Deck.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
  
    try {
      // for each card in the json['cards'], turn it into a JSON; then return the whole list
      cards =
          (json['cards'] as List).map((card) => Card.fromJson(card)).toList();
    } on FormatException {
      // rethrow if it contains a deformed card
      rethrow;
    }
  
    // null check
    if (id == null || title == null || description == null)
      throw FormatException("Cannot parse a deformed Deck");
  }
  
  int get length {
    return cards.length;
  }
  
  @override
  String toString() {
    return 'Deck@${this.id}: { title: \"${this.title}\", description: \"${this.description}\", cards: ${this.cards}}';
  }
  
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'cards': cards.map((card) => card.toJson()).toList()
      };
}
  
```  
  
### StudyRecord.dart
  
```dart
import 'package:json_annotation/json_annotation.dart';
  
part 'StudyRecord.g.dart';
  
// A class combining the study time and result (proficiency) of a card
@JsonSerializable(nullable: false)
class StudyRecord {
  final int proficiency;
  final DateTime datetime;
  
  StudyRecord({this.datetime, this.proficiency});
  
  @override
  String toString() {
    return '$datetime w/ $proficiency';
  }
  
  factory StudyRecord.fromJson(Map<String, dynamic> json) =>
      _$StudyRecordFromJson(json);
  
  Map<String, dynamic> toJson() => _$StudyRecordToJson(this);
}
  
```  
  
### StudyRecord.g.dart
  
```dart
// GENERATED CODE - DO NOT MODIFY BY HAND
  
part of 'StudyRecord.dart';
  
// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************
  
StudyRecord _$StudyRecordFromJson(Map<String, dynamic> json) {
  return StudyRecord(
      datetime: DateTime.parse(json['datetime'] as String),
      proficiency: json['proficiency'] as int);
}
  
Map<String, dynamic> _$StudyRecordToJson(StudyRecord instance) =>
    <String, dynamic>{
      'proficiency': instance.proficiency,
      'datetime': instance.datetime.toIso8601String()
    };
  
```  
  
### CreatePage.dart
  
```dart
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
  
```  
  
### DeckInfoPage.dart
  
```dart
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
    return _DeckInfoPageState();
  }
}
  
class _DeckInfoPageState extends State<DeckInfoPage> {
  final DeckRepository deckRepo = DeckRepository();
  final StudyRecordRepository recordRepo = StudyRecordRepository();
  
  Deck _deck;
  
  _DeckInfoPageState();
  
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
          centerTitle: false,
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
  
              _deck = deckRepo.getDecksById(this.widget.id).first;
  
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
  
```  
  
### HomePage.dart
  
```dart
import 'package:flashlet/components/DecksList.dart';
import 'package:flutter/material.dart';
  
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      new Scaffold(
          appBar: AppBar(
            title: Text("Home"),
            centerTitle: false,
          ),
          body: DecksList(),
          floatingActionButtonLocation: FloatingActionButtonLocation
              .centerFloat,
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, '/create');
            },
            child: const Icon(Icons.add),
            highlightElevation: 16.0,
          ));
}
  
```  
  
### StudyPage.dart
  
```dart
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
  
```  
  
### DeckRepository.dart
  
```dart
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
  
```  
  
### StudyRecordRepository.dart
  
```dart
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
  
```  
  