import 'dart:convert';
import 'dart:io';

import 'package:fastgalery/model/user.dart';

class Comment{
  int id;
  String content;
  DateTime created_at;
  User user;

  Comment(this.id,this.content,this.created_at,this.user);

  factory Comment.fromMap(Map<String,dynamic>map)=>Comment(
    map['id'],
    map['content'],
    DateTime.parse(map['created_at']),
    User.fromMap(map['user']),
  );

  factory Comment.fromJsonString(String jsonString) {

    final Map<String, dynamic> json = jsonDecode(utf8.decode(jsonString.codeUnits));

    return Comment.fromMap(json);
  }

}