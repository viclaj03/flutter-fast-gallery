

import 'dart:convert';

import 'package:fastgalery/model/post.dart';
import 'package:flutter/cupertino.dart';

import 'package:http/http.dart';

class PostData{
  final List<Post> _posts;

  PostData._(this._posts);
//le paso el json y obtengo una lista de posts
  factory PostData.fromJson(String jsonData){
    
    List<dynamic> list = json.decode( utf8.decode(jsonData.codeUnits));

    List<Post> postList = list.map((e) => Post.fromMap(e)).toList();
    return PostData._(postList);
  }

  void Clear(){
    _posts.clear();
  }


  // Método para agregar más datos al objeto PostData
  static void addMoreData(PostData existingData, PostData newData) {
    existingData._posts.addAll(newData._posts);
  }

  Post getPost(int index)=>_posts[index];
  int getSize()=> _posts.length;
  List<Post> getPosts()=>_posts;


}