import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../view_models/image_view_model.dart';
import '../view_models/auth_view_model.dart';
import '../widgets/image_card.dart';

class ImageScreen extends StatefulWidget {
  const ImageScreen({super.key});

  @override
  State<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    final viewModel = Provider.of<ImageViewModel>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Correctly check the permission status before requesting.
      final status = await Permission.photos.status;
      if (status.isDenied) {
        await Permission.photos.request();
      }

      if (viewModel.images.isEmpty) {
        viewModel.fetchImages();
      }
    });

    _scrollController.addListener(() {
      if (_scrollController.position.extentAfter < 200 && !viewModel.isLoading) {
        viewModel.fetchImages();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    final viewModel = Provider.of<ImageViewModel>(context, listen: false);
    await viewModel.refresh();
  }

  void _onTagSelected(String tag) {
    setState(() {
      _isSearching = true;
      _searchController.text = tag;
    });
    Provider.of<ImageViewModel>(context, listen: false).search(tag);
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final imageViewModel = Provider.of<ImageViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search images...',
                  border: InputBorder.none,
                ),
                onSubmitted: (query) {
                  imageViewModel.search(query);
                },
              )
            : const Text('Images'),
        actions: _isSearching
            ? [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _isSearching = false;
                      _searchController.clear();
                      imageViewModel.search('');
                    });
                  },
                ),
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      _isSearching = true;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    authViewModel.signOut();
                  },
                ),
              ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: Consumer<ImageViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading && viewModel.images.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.images.isEmpty) {
              return const Center(child: Text('No images found. Pull to refresh.'));
            }

            return GridView.builder(
              controller: _scrollController,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemCount: viewModel.images.length,
              itemBuilder: (context, index) {
                return ImageCard(
                  image: viewModel.images[index],
                  onTagSelected: _onTagSelected, // Pass the handler here
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: Consumer<ImageViewModel>(
        builder: (context, viewModel, child) {
          return (viewModel.isLoading && viewModel.images.isNotEmpty)
              ? const SizedBox(
                  height: 50,
                  child: Center(child: CircularProgressIndicator()),
                )
              : const SizedBox.shrink();
        },
      ),
    );
  }
}
