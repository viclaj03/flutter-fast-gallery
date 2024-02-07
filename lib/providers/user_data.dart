import 'dart:convert';

import 'package:fastgalery/model/user.dart';


class UserData{
  final List<User> _users;


  UserData._(this._users);



  factory UserData.fromJson(String jsonData){
    List<dynamic> list = json.decode(utf8.decode(jsonData.codeUnits));

    List<User> userList = list.map((e) => User.fromMap(e)).toList();
    return UserData._(userList);

  }

  static void addMoreData(UserData existingData, UserData newData) {
    existingData._users.addAll(newData._users);
  }


  User getPost(int index)=>_users[index];
  int getSize()=> _users.length;
  List<User> getPosts()=>_users;

  void Clear(){
    _users.clear();
  }

  List<User> get users => _users;
}