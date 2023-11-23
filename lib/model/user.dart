class User{
  int id;
  String name;
  String email;
  bool is_active;

  //favorited_by

  User(this.id,this.name,this.email,this.is_active);
  factory User.fromMap(Map<String,dynamic>map)=>User(
      map['id'],
      map['name'],
      map['email'],
      map['is_active']
  );
}