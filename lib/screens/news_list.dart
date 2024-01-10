import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:news_app/screens/popular_news.dart';
import '../database/database_helper.dart';
import 'news_details.dart';
import 'news_list_by_category.dart';
import 'news_search_delegate.dart';
import 'favorite_articles.dart';

class NewsListScreen extends StatefulWidget {
  @override
  _NewsListScreenState createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  List<Map<String, dynamic>> newsList = [];
  List<Map<String, dynamic>> filteredNewsList = [];
  List<bool> isFavoriteList = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<List<Map<String, dynamic>>> GetFavoriteArticles() async {
    return await DatabaseHelper.instance.queryAllRows();
  }

  Future<void> updateFavorites() async {
    // Retrieve the current list of favorites from the database
    final favoritesFromDb = await DatabaseHelper.instance.queryAllRows();

    setState(() {
      // Update the isFavoriteList based on the current favorites in the database
      isFavoriteList = List.generate(
        filteredNewsList.length,
            (index) => favoritesFromDb.any((favorite) => favorite['title'] == filteredNewsList[index]['title']),
      );
    });
  }

  Future<void> fetchData() async {
    final apiKey = '31b03e6382d7e19b4b040510bc8e3194';
    final apiUrl = Uri.parse('http://api.mediastack.com/v1/news?access_key=$apiKey');

    final response = await http.get(apiUrl);

    newsList = await DatabaseHelper.instance.GetAllNews();

    if (response.statusCode == 200) {
      final newNewsList = json.decode(response.body)['data'] as List<dynamic>;

      // Filter out duplicate news by title
      final filteredNewNewsList = newNewsList.where((newNews) {
        final newNewsTitle = newNews['title'] as String;
        return !newsList.any((existingNews) => existingNews['title'] == newNewsTitle);
      }).toList();

      if (filteredNewNewsList.isNotEmpty) {
        // Insert new news into the database
        for (var newNews in filteredNewNewsList) {
          final newsData = {
            'title': newNews['title'],
            'description': newNews['description'],
            'image': newNews['image'] ?? 'https://via.placeholder.com/300',
            'views': newNews['views'] ?? 0,
            'category': newNews['category'],
            'published_date': newNews['published_at'],
          };

          await DatabaseHelper.instance.insertNews(newsData);
        }

        setState(() {
          // Update the state with the combined list of existing news and new news
          newsList = [...newsList, ...filteredNewNewsList];
          isFavoriteList = List.generate(newsList.length, (index) => false);
          filteredNewsList = List.from(newsList);
        });
      } else {
        final favoritesFromDb = await DatabaseHelper.instance.queryAllRows();
        isFavoriteList = List.generate(
          filteredNewsList.length,
              (index) => favoritesFromDb.any((favorite) => favorite['title'] == filteredNewsList[index]['title']),
        );
        filteredNewsList = List.from(newsList);
      }
    } else {

      print("-12552--------------------------------------------------------------------------------------------------");
      print(newsList);
      filteredNewsList = List.from(newsList);
    }
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

  void _toggleFavorite(int index) async {
    final articleTitle = filteredNewsList[index]['title'];
    final isFavorite = !isFavoriteList[index];

    setState(() {
      isFavoriteList[index] = isFavorite;
    });

    // Update favorites in SQLite
    if (isFavorite) {
      await DatabaseHelper.instance.insert({
        'title': filteredNewsList[index]['title'],
        'description': filteredNewsList[index]['description'],
        'image': filteredNewsList[index]['image'],
      });
    } else {
      await DatabaseHelper.instance.delete(articleTitle);
    }
  }

  void _searchNews(String query) {
    setState(() {
      filteredNewsList = newsList.where((news) {
        final title = news['title'] as String;
        final description = news['description'] as String;
        return title.toLowerCase().contains(query.toLowerCase()) ||
            description.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('News App'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              final list = await GetFavoriteArticles();
              showSearch(context: context, delegate: NewsSearchDelegate(newsList: newsList, FavoriteList: list, parentContext: context));
            },
          ),
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => FavoriteArticlesScreen()))
                  .then((value) {
                // This code executes when returning from FavoriteArticlesScreen
                updateFavorites();
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.trending_up), // Add the trending_up icon
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PopularArticlesScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // Widget tree if the future is completed
            return ListView.builder(
              itemCount: filteredNewsList.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 4,
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    leading: _buildImage(filteredNewsList[index]['image'] ?? 'https://via.placeholder.com/80'),
                    title: Text(filteredNewsList[index]['title'] ?? 'No Title Available'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Category: ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NewsListByCategoryScreen(category: filteredNewsList[index]['category']),
                              ),
                            );
                          },
                          child: Text(
                            filteredNewsList[index]['category'] ?? 'No Category Available',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blue, // Add color to make it look like a link
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Views: ${filteredNewsList[index]['views'] ?? 0}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Description: ${_getShortenedDescription(filteredNewsList[index]['description'])}',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: getIcon(index),
                      onPressed: () {
                        _toggleFavorite(index);
                      },
                    ),
                    onTap: () {
                      _navigateToNewsDetails(filteredNewsList[index], index);
                    },
                  ),
                );
              },
            );
          } else {
            // Loading indicator or placeholder
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }

  String _getShortenedDescription(String description) {
    // Limit the description to the first 20 words
    final words = description?.split(' ');
    if (words != null && words.length > 20) {
      return words.take(10).join(' ') + '...';
    } else {
      return description ?? 'No Description Available';
    }
  }

  Icon getIcon(int indexPos){
      if (isFavoriteList != null && isFavoriteList.length > 0 && indexPos >= 0 && indexPos < isFavoriteList.length) {
        return Icon(
          isFavoriteList[indexPos] ? Icons.favorite : Icons.favorite_border,
          color: isFavoriteList[indexPos] ? Colors.red : null,
        );
      } else {
        // Handle the case when isFavoriteList is null, empty, or index is out of range
        return Icon(Icons.favorite_border); // or some default value
      }
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