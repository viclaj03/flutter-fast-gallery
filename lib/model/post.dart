import 'dart:convert';
import 'dart:io';

import 'package:fastgalery/model/user.dart';
import 'package:flutter/services.dart';


import 'dart:async';


const String image_route= 'http://192.168.1.148:8000/static/images/';

class Post{
  int id;
  String title;
  String description;
  String image_url;
  String image_url_ligere;
  bool NSFW;
  String tags;
  DateTime created_at;
  DateTime updated_at;
  User user;
  bool favorited_by_user;

  Post(this.id,this.title,this.description,this.image_url,this.image_url_ligere,this.NSFW,this.tags,this.created_at,this.updated_at,this.user,this.favorited_by_user);

  factory Post.fromMap(Map<String,dynamic>map)=>Post(
      map['id'],
      map['title'],
      map['description'],
      map['image_url'],
      map['image_url_ligere'],
      map['NSFW'],
      map['tags'],
      DateTime.parse(map['created_at']),
      DateTime.parse(map['updated_at']),
      User.fromMap(map['user']),
      map['favorited_by_user']);





  factory Post.fromJsonString(String jsonString) {

    final Map<String, dynamic> json = jsonDecode(utf8.decode(jsonString.codeUnits));
    return Post.fromMap(json);
  }
}








