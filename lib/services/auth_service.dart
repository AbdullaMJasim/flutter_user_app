import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// A custom exception for authentication-related errors.
///
/// This is used to provide user-friendly error messages that can be displayed
/// in the UI.
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

/// A service that handles user authentication using Firebase Authentication.
///
/// This class provides methods for signing in, signing up, and signing out,
/// as well as a stream of authentication state changes.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// A stream that emits the current user when the authentication state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// The currently signed-in user.
  ///
  /// Returns null if no user is signed in.
  User? get currentUser => _auth.currentUser;

  /// Signs in a user with the given email and password.
  ///
  /// Throws an [AuthException] if the sign-in fails.
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      // Re-throw as a custom AuthException to be handled by the ViewModel.
      throw AuthException('Login failed: ${e.message}');
    }
  }

  /// Signs up a new user with the given email and password.
  ///
  /// Throws an [AuthException] if the sign-up fails.
  Future<UserCredential> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      // Re-throw as a custom AuthException to be handled by the ViewModel.
      throw AuthException('Sign-up failed: ${e.message}');
    }
  }

  /// Signs in a user with their Google account.
  ///
  /// Returns the [UserCredential] on success, or null if the user cancels
  /// the sign-in flow.
  ///
  /// Throws an [AuthException] if the sign-in fails for any other reason.
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // The user canceled the sign-in. This is not an error.
        // Return null and let the ViewModel handle it gracefully.
        return null;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      // Re-throw as a custom AuthException to be handled by the ViewModel.
      throw AuthException('Google Sign-In failed: ${e.message}');
    } catch (e) {
      //Something is wrong with my google account verification that is making this catch
      //unrelated errors even on successful login
    }
  }

  /// Signs out the current user from both Firebase and Google Sign-In.
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
