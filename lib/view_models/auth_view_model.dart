import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

/// A view model that manages user authentication state and logic.
///
/// This class interacts with an [AuthService] to perform authentication actions
/// and notifies listeners of changes in the authentication state.
class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  User? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Creates an [AuthViewModel] and starts listening to authentication state changes.
  AuthViewModel() {
    _authService.authStateChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  /// Signs in a user with the given email and password.
  ///
  /// Throws an [AuthException] if the sign-in fails.
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

  /// Signs up a new user with the given email and password.
  ///
  /// Throws an [AuthException] if the sign-up fails.
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

  /// Signs in a user with their Google account.
  ///
  /// Throws an [AuthException] if the sign-in fails.
  Future<void> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.signInWithGoogle();

      if (user == null) {
        // Only throw if the user is actually null (login failed)
        throw AuthException('Google authentication failed');
      }


    } on AuthException {
      rethrow;
    } catch (e, st) {
      // Catch any other exceptions (PlatformException, FirebaseAuthException)
      // and rethrow as a generic AuthException to be handled by the UI.
      throw AuthException('Google authentication failed');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  /// Signs out the current user.
  Future<void> signOut() async {
    await _authService.signOut();
  }
}
