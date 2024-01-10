// favorite_articles.dart

import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class FavoriteArticlesScreen extends StatefulWidget {
  @override
  _FavoriteArticlesScreenState createState() => _FavoriteArticlesScreenState();
}

class _FavoriteArticlesScreenState extends State<FavoriteArticlesScreen> {
  List<Map<String, dynamic>> favoriteArticles = [];

  @override
  void initState() {
    super.initState();
    _loadFavoriteArticles();
  }

  Future<void> _loadFavoriteArticles() async {
    List<Map<String, dynamic>> favorites = await DatabaseHelper.instance.queryAllRows();

    setState(() {
      favoriteArticles = favorites;
    });
  }

  void _removeFavorite(String articleTitle) async {
    await DatabaseHelper.instance.delete(articleTitle);
    _loadFavoriteArticles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Articles'),
      ),
      body: favoriteArticles.isEmpty
          ? Center(
        child: Text('No favorite articles yet.'),
      )
          : ListView.builder(
        itemCount: favoriteArticles.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 4,
            margin: EdgeInsets.all(8),
            child: ListTile(
              title: Text(favoriteArticles[index]['title'] ?? 'No Title Available'),
              subtitle: Text(favoriteArticles[index]['description'] ?? 'No Description Available'),
              leading: _buildImage(favoriteArticles[index]['image'] ?? 'https://via.placeholder.com/80'),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _removeFavorite(favoriteArticles[index]['title']);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    return imageUrl != null
        ? Image.network(
      imageUrl,
      width: 80,
      height: 80,
      fit: BoxFit.cover,
    )
        : Container(); // Return an empty container if the image URL is null
  }
}
