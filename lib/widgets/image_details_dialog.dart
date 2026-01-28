import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import '../models/image_item.dart';

/// A dialog that displays a high-resolution image, its tags, and allows downloading.
class ImageDetailsDialog extends StatefulWidget {
  final ImageItem image;

  const ImageDetailsDialog({super.key, required this.image});

  @override
  State<ImageDetailsDialog> createState() => _ImageDetailsDialogState();
}

class _ImageDetailsDialogState extends State<ImageDetailsDialog> {
  // A global key to access the image widget's context for positioning.
  final GlobalKey _imageKey = GlobalKey();

  // State flags to manage the UI.
  bool _isImageLoaded = false;
  bool _dependenciesInitialized = false;
  double _downloadProgress = 0.0;
  bool _isDownloading = false;

  // State for the floating download button that appears on long-press.
  bool _showDownloadButton = false;
  Offset _longPressPosition = Offset.zero;

  /// Pre-caches the high-resolution image to avoid a flicker when it loads.
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

  /// Downloads the image and saves it to the device's gallery.
  Future<void> _downloadImage() async {
    final isGranted = await Permission.photos.status.isGranted;

    if (isGranted) {
      setState(() {
        _isDownloading = true;
        _downloadProgress = 0.0;
        _showDownloadButton = false; // Hide button once download starts
      });

      try {
        // Use Dio for more advanced networking, like progress tracking.
        final dio = Dio();
        final response = await dio.get(
          widget.image.url,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              setState(() {
                _downloadProgress = received / total;
              });
            }
          },
          options: Options(responseType: ResponseType.bytes),
        );

        await Gal.putImageBytes(Uint8List.fromList(response.data));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image saved to gallery')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving image: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isDownloading = false;
          });
        }
      }
    } else {
      // Inform the user if permission is required.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Photo library permission is required. Please enable it in settings.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use an AnimatedSwitcher to smoothly transition between the skeleton and the content.
    return Dialog(
      clipBehavior: Clip.antiAlias,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isImageLoaded ? _buildContentLoaded() : _buildSkeleton(),
      ),
    );
  }

  /// Builds a skeleton UI to show while the image is loading.
  Widget _buildSkeleton() {
    final theme = Theme.of(context);
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

  /// Builds the main content of the dialog once the image is loaded.
  Widget _buildContentLoaded() {
    final theme = Theme.of(context);

    Widget downloadButton = const SizedBox.shrink();
    if (_showDownloadButton) {
      final RenderBox? imageBox =
          _imageKey.currentContext?.findRenderObject() as RenderBox?;
      if (imageBox != null && imageBox.hasSize) {
        // Logic to position the download button near the long-press position.
        final imageSize = imageBox.size;
        const double buttonRadius = 28.0;
        const double buttonDiameter = buttonRadius * 2;
        const double offset = 20.0; // Distance from the press point

        final bool isNearTop = _longPressPosition.dy < (imageSize.height / 2);

        final double top = isNearTop
            ? _longPressPosition.dy + offset
            : _longPressPosition.dy - buttonDiameter - offset;

        final double left = (_longPressPosition.dx - buttonRadius)
            .clamp(0.0, imageSize.width - buttonDiameter);

        downloadButton = Positioned(
          top: top,
          left: left,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.tertiaryContainer.withOpacity(0.5),
              border: Border.all(
                color: theme.colorScheme.outline,
                width: 1.5,
              ),
            ),
            child: IconButton(
              icon: Icon(Icons.download_rounded,
                  color: theme.colorScheme.onTertiaryContainer),
              onPressed: _downloadImage,
            ),
          ),
        );
      }
    }

    return SingleChildScrollView(
      key: const ValueKey('content'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: () {
              // Hide the download button if the user taps elsewhere on the image.
              if (_showDownloadButton) {
                setState(() {
                  _showDownloadButton = false;
                });
              }
            },
            onLongPressStart: (details) {
              // Show the download button at the long-press location.
              setState(() {
                _longPressPosition = details.localPosition;
                _showDownloadButton = true;
              });
            },
            child: Stack(
              children: [
                Image.network(
                  key: _imageKey, // Assign the key to the image
                  widget.image.url,
                  fit: BoxFit.cover,
                ),
                // Show a download progress indicator.
                if (_isDownloading)
                  Positioned.fill(
                    child: Container(
                      color: theme.colorScheme.scrim.withOpacity(0.5),
                      child: Center(
                        child: CircularProgressIndicator(
                          value: _downloadProgress,
                          backgroundColor:
                              theme.colorScheme.surface.withOpacity(0.5),
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                downloadButton, // Add the dynamically positioned button
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tags',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 8.0),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: widget.image.title.split(',').map((tag) {
                    final trimmedTag = tag.trim();
                    // ActionChips allow the user to select a tag, which closes the
                    // dialog and returns the selected tag to the caller.
                    return ActionChip(
                      label: Text(trimmedTag),
                      onPressed: () {
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
