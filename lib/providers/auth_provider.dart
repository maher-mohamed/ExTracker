import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  User? _user;
  bool _isLoading = false;
  String _error = '';

  User? get user => _user;
  bool get isLoading => _isLoading;
  String get error => _error;

  AuthProvider() {
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> signIn(String email, String password) async {
    _setLoading(true);
    try {
      await _authService.signInWithEmailPassword(email, password);
      _error = '';
    } on FirebaseAuthException catch (e) {
      _error = e.message ?? 'Authentication failed';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signUp(String email, String password) async {
    _setLoading(true);
    try {
      await _authService.signUpWithEmailPassword(email, password);
      _error = '';
    } on FirebaseAuthException catch (e) {
      _error = e.message ?? 'Registration failed';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInWithGoogle() async {
    _setLoading(true);
    try {
      await _authService.signInWithGoogle();
      _error = '';
    } catch (e) {
      _error = 'Google sign-in failed';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<void> resetPassword(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProfilePicture(File imageFile) async {
    if (_user == null) return;
    _setLoading(true);
    try {
      final ref = _storage.ref().child('user_profiles').child('${_user!.uid}.jpg');
      await ref.putFile(imageFile);
      final url = await ref.getDownloadURL();
      // Add a timestamp to bypass caching
      final timestampedUrl = '$url&t=${DateTime.now().millisecondsSinceEpoch}';
      await _user!.updatePhotoURL(timestampedUrl);
      await _user!.reload();
      _user = FirebaseAuth.instance.currentUser;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update profile picture';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateDisplayName(String newName) async {
    if (_user == null) return;
    _setLoading(true);
    try {
      await _user!.updateDisplayName(newName);
      await _user!.reload();
      _user = FirebaseAuth.instance.currentUser;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update name';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
