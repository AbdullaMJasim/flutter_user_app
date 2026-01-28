import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/image_item.dart';

/// A service for interacting with the Pixabay API to fetch images.
class PixabayApiService {

  static final String _apiKey = dotenv.env['PIXABAY_API_KEY'] ?? '';
  static const String _baseUrl = 'https://pixabay.com/api/';

  /// Fetches a list of images from the Pixabay API.
  ///
  /// - [page]: The page number to fetch.
  /// - [perPage]: The number of images to fetch per page.
  /// - [query]: An optional search query.
  ///
  /// Returns a list of [ImageItem] on success, or an empty list on failure.
  Future<List<ImageItem>> fetchImages({
    int page = 1,
    int perPage = 20,
    String query = '',
  }) async {
    if (_apiKey.isEmpty) {
      debugPrint('Pixabay API key is not set.');
      return [];
    }

    final formattedQuery = query.isNotEmpty ? '&q=${Uri.encodeComponent(query)}' : '';
    final url = '$_baseUrl?key=$_apiKey&page=$page&per_page=$perPage&safesearch=true$formattedQuery';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List hits = data['hits'];
        return hits.map((item) => ImageItem.fromJson(item)).toList();
      } else {
        debugPrint('Pixabay API error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Failed to fetch images: $e');
      return [];
    }
  }
}
