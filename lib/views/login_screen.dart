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
  final _passwordFocusNode = FocusNode();
  bool _isLogin = true; // To toggle between login and sign-up
  bool _passwordVisible = false;
  bool _isPasswordFocused = false;

  final Map<String, bool> _passwordValidation = {
    'length': false,
    'uppercase': false,
    'lowercase': false,
    'special': false,
  };

  void _validatePassword(String password) {
    setState(() {
      _passwordValidation['length'] = password.length >= 8;
      _passwordValidation['uppercase'] = password.contains(RegExp(r'[A-Z]'));
      _passwordValidation['lowercase'] = password.contains(RegExp(r'[a-z]'));
      _passwordValidation['special'] =
          password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  @override
  void initState() {
    super.initState();
    _passwordFocusNode.addListener(() {
      setState(() {
        _isPasswordFocused = _passwordFocusNode.hasFocus;
      });
    });
    _passwordController.addListener(() {
      if (!_isLogin) {
        _validatePassword(_passwordController.text);
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

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
      body: SingleChildScrollView(
        child: Padding(
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
                focusNode: _passwordFocusNode,
                obscureText: !_passwordVisible,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: !_isLogin &&
                              !_passwordValidation.values.every((v) => v)
                          ? Colors.red
                          : Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
              if (!_isLogin && _isPasswordFocused)
                const SizedBox(height: 16.0),
              if (!_isLogin && _isPasswordFocused)
                Column(
                  children: [
                    _buildValidationRow(
                        'At least 8 characters', _passwordValidation['length'] ?? false),
                    _buildValidationRow('At least one uppercase letter',
                        _passwordValidation['uppercase'] ?? false),
                    _buildValidationRow('At least one lowercase letter',
                        _passwordValidation['lowercase'] ?? false),
                    _buildValidationRow('At least one special character',
                        _passwordValidation['special'] ?? false),
                  ],
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
                        final isPasswordValid =
                            _passwordValidation.values.every((v) => v);
                        if (!isPasswordValid) {
                          _showError('Please fix the errors in the password.');
                          return;
                        }
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
      ),
    );
  }

  Widget _buildValidationRow(String text, bool isValid) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.remove_circle_outline,
          color: isValid ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 8.0),
        Text(text),
      ],
    );
  }
}
