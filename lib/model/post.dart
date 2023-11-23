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
  bool NSFW;
  DateTime created_at;
  DateTime updated_at;
  User user;
  //favorited_by

  Post(this.id,this.title,this.description,this.image_url,this.NSFW,this.created_at,this.updated_at,this.user);

  factory Post.fromMap(Map<String,dynamic>map)=>Post(
      map['id'],
      map['title'],
      map['description'],
      map['image_url'],
      map['NSFW'],
      DateTime.parse(map['created_at']),
      DateTime.parse(map['updated_at']),
      User.fromMap(map['user']));
}



