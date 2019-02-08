import 'package:flutter/material.dart';
import 'HomePage.dart';

void main() {
  runApp(new MaterialApp(
    theme: new ThemeData(
      // Define the default Brightness and Colors
      brightness: Brightness.dark,
      accentColor: Color(0xffd72323),
      
      // Define the default Font Family
      fontFamily: 'Montserrat',
      
      // Define the default TextTheme. Use this to specify the default
      // text styling for headlines, titles, bodies of text, and more.
      textTheme: TextTheme(
        headline: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
        title: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
        body1: TextStyle(fontSize: 14.0, fontFamily: 'Hind', color: Color(0xffeeeeee)),
      ),
    ),
    title: "Flashlet",
    home: HomePage(),
  ));
}