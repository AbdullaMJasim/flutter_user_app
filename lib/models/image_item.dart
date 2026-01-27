class ImageItem {
  final int id;
  final String title;
  final String url;
  final String thumbnailUrl;

  ImageItem({
    required this.id,
    required this.title,
    required this.url,
    required this.thumbnailUrl,
  });

  factory ImageItem.fromJson(Map<String, dynamic> json) {
    return ImageItem(
      id: json['id'],
      title: json['tags'] ?? '', // Use tags as the title
      url: json['webformatURL'] ?? '',
      thumbnailUrl: json['previewURL'] ?? '',
    );
  }
}
