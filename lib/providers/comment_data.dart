import 'dart:convert';

import 'package:fastgalery/model/comment.dart';


class CommentData{
  final List<Comment> _comments;

  CommentData._(this._comments);


  factory CommentData.fromJson(String jsonData){

    List<dynamic> list = json.decode( utf8.decode(jsonData.codeUnits));

    List<Comment> coomentList = list.map((e) => Comment.fromMap(e)).toList();
    return CommentData._(coomentList);
  }



  void addData(List<Comment> newComments){
    _comments.addAll(newComments);
  }


  void deleteCommentById(int postId) {
    _comments.removeWhere((comment) => comment.id == postId);
  }

  void addComment(Comment comment) {
    _comments.insert(0,comment);
  }

  List<Comment> getComments ()=> _comments;

  int getSize()=>_comments.length;

  Comment getComment(int index)=>_comments[index];
}