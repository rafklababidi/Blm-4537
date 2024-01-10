// lib/screens/main_screen.dart
import 'package:flutter/material.dart';
import 'news_list.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Screen'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate to the NewsListScreen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NewsListScreen(),
              ),
            );
          },
          child: Text('Go to News List'),
        ),
      ),
    );
  }
}
