import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../secret/my_credentials.dart';
import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

  bool get isAuth {
    return getToken != null;
  }

  String get getToken {
    if (_token != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _expiryDate != null) {
      return _token;
    }

    return null;
  }

  Future<void> _authenticate(
      String email, String password, String authCategory) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$authCategory?key=${MyCredentials.PROJ6_API_KEY}';

    try {
      final response = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));

      print('$authCategory response..... ${json.decode(response.body)}');

      final responseData = json.decode(response.body);

      // we create custom error handling because firebase does not throw error
      // in case there is an error, the error will show in the response as follows
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }

      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData['expiresIn'],
          ),
        ),
      );

      _autoSignOut();

      notifyListeners();

      // save data on device storage
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate
            .toIso8601String() // toIso860String is string format for DateTime. `toIso8601String` to convert DataTime to String value
      });
      prefs.setString('userData', userData);
    } catch (err) {
      print('_authenticate_err..... $err');

      throw err;
    }
  }

  Future<void> signUp(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> signIn(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future<void> signOut() async {
    _token = null;
    _expiryDate = null;
    _userId = null;
    _authTimer = null;

    final prefs = await SharedPreferences.getInstance();
    // prefs.remove('userData'); // to remove specific key ONLY
    prefs.clear(); // to remove ALL keys

    notifyListeners();
  }

  void _autoSignOut() {
    // to clear previous set authTimer if available
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), signOut);
  }

  Future<bool> tryAutoSignIn() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }

    final userData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    final tokenExpiryDate = DateTime.parse(userData['expiryDate']);

    if (tokenExpiryDate.isBefore(DateTime.now()) ||
        userData['token'] == null ||
        userData['userId'] == null) {
      return false;
    }

    _token = userData['token'];
    _userId = userData['userId'];
    _expiryDate = DateTime.parse(userData['expiryDate']);

    _autoSignOut();

    notifyListeners();

    return true;
  }
}
