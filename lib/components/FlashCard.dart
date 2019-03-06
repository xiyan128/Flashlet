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
