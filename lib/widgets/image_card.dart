import 'package:flutter/material.dart';
import '../models/image_item.dart';
import 'image_details_dialog.dart';

class ImageCard extends StatelessWidget {
  final ImageItem image;

  const ImageCard({super.key, required this.image});

  void _showDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ImageDetailsDialog(image: image),
    );
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
