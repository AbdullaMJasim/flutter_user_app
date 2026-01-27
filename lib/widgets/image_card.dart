import 'package:flutter/material.dart';
import '../models/image_item.dart';
import 'image_details_dialog.dart';

class ImageCard extends StatelessWidget {
  final ImageItem image;
  final Function(String) onTagSelected;

  const ImageCard({
    super.key,
    required this.image,
    required this.onTagSelected,
  });

  Future<void> _showDetails(BuildContext context) async {
    final selectedTag = await showDialog<String>(
      context: context,
      builder: (context) => ImageDetailsDialog(image: image),
    );

    if (selectedTag != null && selectedTag.isNotEmpty) {
      onTagSelected(selectedTag);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showDetails(context),
        child: Image.network(
          image.thumbnailUrl,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
