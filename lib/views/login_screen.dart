import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/auth_view_model.dart';
import '../services/auth_service.dart'; // Import AuthException

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true; // To toggle between login and sign-up

  void _showError(String message) {
    if (mounted) {
      // Clear any previous snackbar before showing a new one.
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Login' : 'Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 32.0),
            if (authViewModel.isLoading)
              const CircularProgressIndicator()
            else ...[
              ElevatedButton(
                onPressed: () async {
                  //Hide any stale snackbar before starting.
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();

                  final email = _emailController.text.trim();
                  final password = _passwordController.text.trim();
                  if (email.isEmpty || password.isEmpty) {
                    _showError('Please fill in all fields.');
                    return;
                  }

                  try {
                    if (_isLogin) {
                      await authViewModel.signInWithEmailAndPassword(
                          email, password);
                    } else {
                      await authViewModel.signUpWithEmailAndPassword(
                          email, password);
                    }
                  } on AuthException catch (e) {
                    _showError(e.message);
                  }
                },
                child: Text(_isLogin ? 'Login' : 'Sign Up'),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton.icon(
                onPressed: () async {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  try {
                    await authViewModel.signInWithGoogle();
                  } on AuthException catch (e) {
                    _showError(e.message);
                  }
                },
                icon: const Icon(Icons.login),
                label: const Text('Sign in with Google'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                  });
                },
                child: Text(
                    _isLogin ? 'Create an account' : 'Have an account? Login'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
