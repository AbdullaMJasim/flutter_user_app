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

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    final userCredential = await _authService.signInWithEmailAndPassword(email, password);
    _isLoading = false;
    notifyListeners();
    return userCredential != null;
  }

  Future<bool> signUpWithEmailAndPassword(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    final userCredential = await _authService.signUpWithEmailAndPassword(email, password);
    _isLoading = false;
    notifyListeners();
    return userCredential != null;
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();
    final userCredential = await _authService.signInWithGoogle();
    _isLoading = false;
    notifyListeners();
    return userCredential != null;
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}
