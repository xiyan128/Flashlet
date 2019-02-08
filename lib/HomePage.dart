import 'package:flutter/material.dart';
import 'DeckList.dart';

class HomePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text("Flashlet"),
        // backgroundColor: Color(0xff303841),
        centerTitle: true,
        // elevation: 6,
      ),
      body: DeckList(),
      bottomNavigationBar: BottomAppBar(
        // elevation: 6.0,
        shape: CircularNotchedRectangle(),
        notchMargin: 5.0,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(icon: Icon(Icons.menu), onPressed: () {}),
            IconButton(icon: Icon(Icons.search), onPressed: () {}),
          ]
        )
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
        highlightElevation: 16.0,
      )
    );
  }
}