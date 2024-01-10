// lib/main.dart
import 'package:flutter/material.dart';
import 'package:news_app/screens/login_screen.dart';
import 'package:news_app/screens/main_screen.dart';
import 'screens/news_list.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(), // Change this to the main screen widget you want
    );
  }
}
