import 'package:flutter/material.dart';
import '../models/image_item.dart';
import 'image_details_dialog.dart';

/// A widget that displays a single image in a card.
///
/// When the card is tapped, it shows an [ImageDetailsDialog] with more
/// information about the image.
class ImageCard extends StatelessWidget {
  final ImageItem image;

  /// A callback that is invoked when a tag is selected in the details dialog.
  final Function(String) onTagSelected;

  const ImageCard({
    super.key,
    required this.image,
    required this.onTagSelected,
  });

  /// Shows the [ImageDetailsDialog] when the card is tapped.
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
