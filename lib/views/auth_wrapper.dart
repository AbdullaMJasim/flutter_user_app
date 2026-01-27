import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/auth_view_model.dart';
import '../view_models/image_view_model.dart';
import 'login_screen.dart';
import 'image_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    if (authViewModel.user != null) {
      // If the user is logged in, provide a fresh ImageViewModel and show the ImageScreen.
      return ChangeNotifierProvider(
        create: (_) => ImageViewModel(),
        child: const ImageScreen(),
      );
    } else {
      // If the user is not logged in, show the LoginScreen.
      return const LoginScreen();
    }
  }
}
