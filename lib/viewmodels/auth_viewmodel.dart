import 'package:flutter/material.dart';

class AuthViewmodel extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _userId = "";
  String _userName = "";

  bool get isLoggedIn => _isLoggedIn;
  String get userId => _userId;
  String get userName => _userName;

  void login(String userId, String userName) {
    _userId = userId;
    _userName = userName;
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _userId = "";
    _userName = "";
    _isLoggedIn = false;
    notifyListeners();
  }
}