import 'package:flutter/material.dart';
import '../models/image_item.dart';

class ImageCard extends StatelessWidget {
  final ImageItem image;

  const ImageCard({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Expanded(
            child: Image.network(
              image.thumbnailUrl,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(image.title, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
