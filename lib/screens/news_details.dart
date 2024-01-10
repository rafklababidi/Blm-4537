import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NewsDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> newsItem;

  NewsDetailsScreen({required this.newsItem});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('News Details'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              newsItem['title'],
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            _buildImage(newsItem['image']),
            SizedBox(height: 16),
            Text(
              'Content:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              newsItem['description'],
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    return CachedNetworkImage(
      imageUrl: imageUrl ?? 'https://via.placeholder.com/300', // Use a placeholder if the image URL is null
      placeholder: (context, url) => CircularProgressIndicator(),
      errorWidget: (context, url, error) => Icon(Icons.error),
      width: double.infinity,
      height: 200,
      fit: BoxFit.cover,
    );
  }
}
