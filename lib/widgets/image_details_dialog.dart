import 'package:flutter/material.dart';
import '../models/image_item.dart';

class ImageDetailsDialog extends StatefulWidget {
  final ImageItem image;

  const ImageDetailsDialog({super.key, required this.image});

  @override
  State<ImageDetailsDialog> createState() => _ImageDetailsDialogState();
}

class _ImageDetailsDialogState extends State<ImageDetailsDialog> {
  bool _isImageLoaded = false;
  bool _dependenciesInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_dependenciesInitialized) {
      precacheImage(NetworkImage(widget.image.url), context).then((_) {
        if (mounted) {
          setState(() {
            _isImageLoaded = true;
          });
        }
      });
      _dependenciesInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      clipBehavior: Clip.antiAlias,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isImageLoaded ? _buildContentLoaded() : _buildSkeleton(),
      ),
    );
  }

  Widget _buildSkeleton() {
    final theme = Theme.of(context);
    // A static skeleton that mimics the final layout without any animation.
    return SingleChildScrollView(
      key: const ValueKey('skeleton'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 200, // Fixed height for the image placeholder
            color: theme.colorScheme.surfaceContainerHighest,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 24, // Placeholder for the 'Tags' title
                  width: 80,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                const SizedBox(height: 16.0),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: List.generate(
                    3, // Show 3 placeholder chips
                    (index) => Chip(
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      label: const SizedBox(width: 60, height: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentLoaded() {
    return SingleChildScrollView(
      key: const ValueKey('content'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.network(
            widget.image.url,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tags',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8.0),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: widget.image.title.split(',').map((tag) {
                    final trimmedTag = tag.trim();
                    return ActionChip(
                      label: Text(trimmedTag),
                      onPressed: () {
                        // Pop the dialog and return the selected tag
                        Navigator.of(context).pop(trimmedTag);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }
}
