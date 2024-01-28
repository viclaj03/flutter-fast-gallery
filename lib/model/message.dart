import 'dart:convert';

import 'package:fastgalery/model/user.dart';



class Message {
  int id;
  String title;
  String content;
  DateTime created_at;
  User user_sender;
  User user_reciber;
  bool reed;

  Message(this.id, this.title,this.content ,this.created_at, this.user_sender,this.user_reciber,this.reed);

  factory Message.fromMap(Map<String,dynamic>map)=>Message(
    map['id'],
    map['title'],
    map['content'],
    DateTime.parse(map['created_at']),
    User.fromMap(map['user_sender']),
    User.fromMap(map['user_reciber']),
    map['reed'],
  );

  factory Message.fromJsonString(String jsonString) {

    final Map<String, dynamic> json = jsonDecode(utf8.decode(jsonString.codeUnits));

    return Message.fromMap(json);
  }

}