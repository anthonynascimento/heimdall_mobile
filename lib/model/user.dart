import 'package:heimdall/model/etudiant.dart';
import 'package:heimdall/model/professeur.dart';

abstract class User {
  static final String ETUDIANT = 'Etudiant';
  static final String PROFESSEUR = 'Professeur';
  final int id;
  final String username;
  String firstname;
  String lastname;
  DateTime lastLogin;
  get type;
  String get fullName => firstname + ' ' + lastname;
  String get fullNameReversed => lastname + ' ' + firstname;

  User({this.id, this.username, this.firstname, this.lastname, this.lastLogin});

  factory User.fromJson(Map<String, dynamic> json) {
    if (json['role'] == ETUDIANT) {
      return Etudiant.fromJson(json["user"]);
    } else if (json['role'] == PROFESSEUR) {
      return Professeur.fromJson(json["user"]);
    }
    throw new Exception('User type not supported.');
  }

  Map<String, dynamic> toJson();
}