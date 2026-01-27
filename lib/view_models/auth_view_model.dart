import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  User? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AuthViewModel() {
    _authService.authStateChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.signInWithEmailAndPassword(email, password);
    } on AuthException {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.signUpWithEmailAndPassword(email, password);
    } on AuthException {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.signInWithGoogle(); // returns User? or null

      if (user == null) {
        // Only throw if the user is actually null (login failed)
        throw AuthException('Google authentication failed');
      }


    } on AuthException {
      rethrow;
    } catch (e, st) {
      // Catch any other exceptions (PlatformException, FirebaseAuthException)
      print('Google sign-in error: $e\n$st');
      // Decide if you want to show the error to the user
      throw AuthException('Google authentication failed');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> signOut() async {
    await _authService.signOut();
  }
}
