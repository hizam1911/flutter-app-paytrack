import 'package:cloud_firestore/cloud_firestore.dart';

class Users {
  //properties
  String email = "";
  String username = "";
  String phonenum = "";
  String password = "";

  //constructor
  Users({
    required this.email,
    required this.username,
    required this.phonenum,
    required this.password
  });

  //factory method
  Users.fromJson(Map<String, Object?> json)
  : this(
    email: json['email']! as String,
    username: json['username']! as String,
    phonenum: json['phonenum']! as String,
    password: json['password']! as String,
  );

  Users copyWith({
    String? email,
    String? username,
    String? phonenum,
    String? password,
  }) {
    return Users(
      email: email ?? this.email,
      username: username ?? this.username,
      phonenum: phonenum ?? this.phonenum,
      password: password ?? this.password,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'email' : email,
      'username' : username,
      'phonenum' : phonenum,
      'password' : password,
    };
  }

}