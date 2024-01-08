import 'package:flutter/cupertino.dart';

import 'package:shared_preferences/shared_preferences.dart';



Future<void> saveToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('token', token);
}



Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('token');
}


Future<Future<bool>> removeToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.remove('token');
}


Future<void> saveIdUser(int idUser) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setInt('idUser', idUser);
}

Future<int?> getIdUser() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('idUser');
}

Future<void> saveUsername(String username) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('username', username);
}

Future<String?> getUsername() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('username');
}


Future<void> saveEmail(String username) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('email', username);
}

Future<String?> getEmail() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('email');
}





Future<Future<bool>> removeUserData() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove('username');
  prefs.remove('email');
  return (prefs.remove('idUser'));
}












