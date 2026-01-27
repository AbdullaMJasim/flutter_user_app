import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  @override
  void initState() {
    super.initState();
    final viewModel = Provider.of<ImageViewModel>(context, listen: false);

    // Fetch images after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    super.dispose();
  }

  Future<void> _onRefresh() async {
    final viewModel = Provider.of<ImageViewModel>(context, listen: false);
    await viewModel.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Images'),
        actions: [
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
                return ImageCard(image: viewModel.images[index]);
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
