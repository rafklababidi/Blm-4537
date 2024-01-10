// popular_articles_screen.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../database/database_helper.dart';
import 'news_details.dart';

class PopularArticlesScreen extends StatefulWidget {
  @override
  _PopularArticlesScreenState createState() => _PopularArticlesScreenState();
}

class _PopularArticlesScreenState extends State<PopularArticlesScreen> {
  late Future<List<Map<String, dynamic>>> popularNews;
  String sortingOrder = 'most_views';

  @override
  void initState() {
    super.initState();
    popularNews = DatabaseHelper.instance.getPopularNews(sortingOrder);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Popular Articles'),
        actions: [
          // Dropdown for sorting order
          DropdownButton<String>(
            value: sortingOrder,
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  sortingOrder = newValue;
                  popularNews = DatabaseHelper.instance.getPopularNews(sortingOrder);
                });
              }
            },
            items: <String>['most_views', 'least_views'].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value == 'most_views' ? 'Most Views' : 'Least Views'),
              );
            }).toList(),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: popularNews,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
            return Center(child: Text('No popular articles available'));
          } else {
            final popularArticles = snapshot.data as List<Map<String, dynamic>>;
            return ListView.builder(
              itemCount: popularArticles.length,
              itemBuilder: (context, index) {
                final article = popularArticles[index];
                return Card(
                  elevation: 4,
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    leading: _buildImage(article['image'] ?? 'https://via.placeholder.com/80'),
                    title: Text(article['title'] ?? 'No Title Available'),
                    subtitle: Text('Views: ${article['views'] ?? 0}'),
                    onTap: () {
                      // Handle tapping on the article, navigate to details or perform any action
                      _navigateToNewsDetails(article, index);
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  void _navigateToNewsDetails(Map<String, dynamic> newsItem, int index) async {
    // Increment views in the local state
    setState(() {
      //   filteredNewsList[index]['views'] = (filteredNewsList[index]['views'] ?? 0) + 1;
    });

    // Increment views in the database
    await DatabaseHelper.instance.updateViews(newsItem['title'], (newsItem['views'] ?? 0) + 1);

    // Navigate to the details screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewsDetailsScreen(newsItem: newsItem),
      ),
    );
  }

  Widget _buildImage(String? imageUrl) {
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
