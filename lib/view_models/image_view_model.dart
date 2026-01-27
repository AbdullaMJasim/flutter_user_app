import 'package:flutter/material.dart';
import '../models/image_item.dart';
import '../services/pixabay_api_service.dart';

class ImageViewModel extends ChangeNotifier {
  final PixabayApiService _apiService = PixabayApiService();
  List<ImageItem> _images = [];
  bool _isLoading = false;
  int _page = 1;
  bool _hasMoreImages = true;

  List<ImageItem> get images => _images;
  bool get isLoading => _isLoading;

  Future<void> fetchImages() async {
    if (_isLoading || !_hasMoreImages) return;

    _isLoading = true;
    notifyListeners();

    try {
      final newImages = await _apiService.fetchImages(page: _page);

      if (newImages.isNotEmpty) {
        _images.addAll(newImages);
        _page++;
      } else {
        _hasMoreImages = false;
      }
    } catch (e) {
      print('Error in ImageViewModel: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    _images.clear();
    _page = 1;
    _hasMoreImages = true;
    await fetchImages();
  }
}
