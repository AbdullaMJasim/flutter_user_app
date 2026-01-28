import 'package:flutter/material.dart';
import '../models/image_item.dart';
import '../services/pixabay_api_service.dart';

/// Manages the state for fetching and displaying images from the Pixabay API.
class ImageViewModel extends ChangeNotifier {
  final PixabayApiService _apiService = PixabayApiService();

  /// The list of currently loaded images.
  List<ImageItem> _images = [];
  List<ImageItem> get images => _images;

  /// Whether new images are currently being loaded.
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// The current page number for pagination.
  int _page = 1;

  bool _hasMoreImages = true;

  /// The current search query.
  String _currentQuery = '';

  /// Fetches the next page of images from the API.
  ///
  /// If a search query is active, it fetches images matching the query.
  /// Otherwise, it fetches the latest images.
  Future<void> fetchImages() async {
    if (_isLoading || !_hasMoreImages) return;

    _isLoading = true;
    notifyListeners();

    try {
      final newImages = await _apiService.fetchImages(page: _page, query: _currentQuery);

      if (newImages.isNotEmpty) {
        _images.addAll(newImages);
        _page++;
      } else {
        _hasMoreImages = false;
      }
    } catch (e, st) {
      debugPrint('Failed to fetch images: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Performs a new search with the given [query].
  ///
  /// This clears the existing images and fetches the first page of results
  /// for the new query.
  Future<void> search(String query) async {
    _currentQuery = query;
    _images.clear();
    _page = 1;
    _hasMoreImages = true;
    await fetchImages();
  }

  /// Refreshes the list of images.
  ///
  /// This clears the existing images and fetches the first page of results again
  /// for the current query.
  Future<void> refresh() async {
    _images.clear();
    _page = 1;
    _hasMoreImages = true;
    await fetchImages();
  }
}
