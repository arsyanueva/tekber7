import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../utils/session_manager.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;
  bool get isLoggedIn => _user != null;

  Future<void> setUser(UserModel user) async {
    _user = user;
    await SessionManager.saveUser(user);
    notifyListeners();
  }

  Future<void> loadSession() async {
    _user = await SessionManager.getUser();
    notifyListeners();
  }

  Future<void> logout() async {
    _user = null;
    await SessionManager.clear();
    notifyListeners();
  }
}
