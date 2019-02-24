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