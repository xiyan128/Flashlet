import 'package:flashlet/components/DecksList.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      new Scaffold(
          appBar: AppBar(
            title: Text("Flashlet"),
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
