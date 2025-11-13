import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  User? _currentUser;
  Map<String, dynamic>? _userProfile;
  String? _role;
  bool _isLoading = false;
  String? _error;
  ThemeMode _themeMode = ThemeMode.system;

  User? get currentUser => _currentUser;
  Map<String, dynamic>? get userProfile => _userProfile;
  String? get role => _role;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ThemeMode get themeMode => _themeMode;

  AppState() {
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    _setLoading(true);
    try {
      // Load theme preference
      await _loadThemeMode();

      // Listen to auth state changes
      FirebaseAuth.instance.authStateChanges().listen((User? user) async {
        _currentUser = user;
        if (user != null) {
          await _loadUserProfile(user.uid);
        } else {
          _userProfile = null;
          _role = null;
        }
        notifyListeners();
      });
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadUserProfile(String uid) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists) {
        _userProfile = doc.data() as Map<String, dynamic>;
        _role = _userProfile!['role'] as String?;
        
        // Save user ID to shared preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', uid);
      }
    } catch (e) {
      _setError('Error loading user profile: $e');
    }
  }

  Future<void> refreshUserProfile() async {
    if (_currentUser != null) {
      await _loadUserProfile(_currentUser!.uid);
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  Future<void> _loadThemeMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? themeModeString = prefs.getString('themeMode');
    if (themeModeString != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (e) => e.toString() == themeModeString,
        orElse: () => ThemeMode.system,
      );
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode.toString());
    notifyListeners();
  }

  bool isUserRT() {
    return _role == 'rt';
  }

  bool isUserRW() {
    return _role == 'rw';
  }

  bool isUserKelurahan() {
    return _role == 'kelurahan';
  }

  bool isUserWarga() {
    return _role == 'warga';
  }

  String getUserRT() {
    return _userProfile?['rt'] ?? '';
  }

  String getUserRW() {
    return _userProfile?['rw'] ?? '';
  }

  String getUserKelurahan() {
    return _userProfile?['kelurahan'] ?? '';
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Clear all stored preferences
    } catch (e) {
      _setError('Error signing out: $e');
    }
  }
}