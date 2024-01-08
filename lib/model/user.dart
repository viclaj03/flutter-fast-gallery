import 'dart:convert';

class User{
  int id;
  String name;
  String? email;
  bool is_active;
  bool? subscribe;
  int? post_count;
  int? follower_count;
  int? like_counts;

  //favorited_by

  User(this.id,this.name,this.email,this.is_active,this.subscribe,this.post_count,this.follower_count,this.like_counts);
  factory User.fromMap(Map<String,dynamic>map)=>User(
      map['id'],
      map['name'],
      map['email'],
      map['is_active'],
      map['subscribe'],
      map['post_count'],
      map['follower_count'] ?? 0,
      map['like_counts']
  );


  factory User.fromJson(String jsonString){
    final Map<String, dynamic> json = jsonDecode(utf8.decode(jsonString.codeUnits));
    return User.fromMap(json);
  }
}