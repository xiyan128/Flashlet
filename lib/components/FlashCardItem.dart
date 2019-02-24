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
