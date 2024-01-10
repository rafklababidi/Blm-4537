import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';

import '../database/database_helper.dart';

class NewsListByCategoryScreen extends StatefulWidget {
  final String category;

  NewsListByCategoryScreen({required this.category});

  @override
  _NewsListByCategoryScreenState createState() => _NewsListByCategoryScreenState();
}

class _NewsListByCategoryScreenState extends State<NewsListByCategoryScreen> {
  List<dynamic> newsList = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      // Fetch news from the local database for the specific category
      final newsFromDb = await DatabaseHelper.instance.getNewsByCategory(widget.category);

      setState(() {
        newsList = newsFromDb;
      });
    } catch (e) {
      print('Failed to load news from the database: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('News App - ${widget.category}'),
      ),
      body: ListView.builder(
        itemCount: newsList.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 4,
            margin: EdgeInsets.all(8),
            child: ListTile(
              leading: _buildImage(newsList[index]['image'] ?? 'https://via.placeholder.com/80'),
              title: Text(newsList[index]['title'] ?? 'No Title Available'),
              subtitle: Text(newsList[index]['description'] ?? 'No Description Available'),
              onTap: () {
                // Handle tapping on the news item, e.g., navigate to details
                // Similar to what you did in _navigateToNewsDetails
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    return CachedNetworkImage(
      imageUrl: imageUrl ?? 'https://via.placeholder.com/80',
      placeholder: (context, url) => CircularProgressIndicator(),
      errorWidget: (context, url, error) => Icon(Icons.error),
      width: 80,
      height: 80,
      fit: BoxFit.cover,
    );
  }
}
