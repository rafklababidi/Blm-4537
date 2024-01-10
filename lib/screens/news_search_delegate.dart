import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'news_details.dart';

class NewsSearchDelegate extends SearchDelegate<String> {
  final BuildContext parentContext;
  final List<dynamic> newsList;
  final List<Map<String, dynamic>> FavoriteList;

  NewsSearchDelegate({
    required this.parentContext,
    required this.newsList,
    required this.FavoriteList,
  });

  @override
  String get searchFieldLabel => 'Search News';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(parentContext, "");
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final filteredNews = newsList.where((news) {
      final title = news['title'] as String?;
      final description = news['description'] as String?;

      return (title != null && title.toLowerCase().contains(query.toLowerCase())) ||
          (description != null && description.toLowerCase().contains(query.toLowerCase()));
    }).toList();

    return ListView.builder(
      itemCount: filteredNews.length,
      itemBuilder: (context, index) {
        final isFavorite = FavoriteList.any((favorite) => favorite['title'] == filteredNews[index]['title']);
print("-----------------------------");
print(FavoriteList);
        return Card(
          elevation: 4,
          margin: EdgeInsets.all(8),
          child: ListTile(
            leading: _buildImage(filteredNews[index]['image'] ?? 'https://via.placeholder.com/80'),
            title: Text(filteredNews[index]['title'] ?? 'No Title Available'),
            subtitle: Text(filteredNews[index]['description'] ?? 'No Description Available'),
            trailing: IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : null,
              ),
              onPressed: () {
                // Handle favorite toggle for search results
                // You may want to call a function in the NewsListScreen to update the original list
              },
            ),
            onTap: () {
              _navigateToNewsDetails(parentContext, filteredNews[index]); // Navigate to details screen
            },
          ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Center(
      child: Text('Type in the search box to see suggestions'),
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

  void _navigateToNewsDetails(BuildContext context, Map<String, dynamic> newsItem) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewsDetailsScreen(newsItem: newsItem),
      ),
    );
  }
}
