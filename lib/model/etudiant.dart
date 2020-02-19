import 'package:heimdall/model/class_group.dart';
import 'package:heimdall/model/student_presence.dart';
import 'package:heimdall/model/user.dart';

class Etudiant extends User {
  String photo;
  ClassGroup classGroup;
  List<StudentPresence> presences;
  String get type => 'etudiant';

  Etudiant(
      {int id, String username, String firstname, String lastname, DateTime lastLogin})
      : super(id: id,
                  username: username,
                  firstname: firstname,
                  lastname: lastname,
                  lastLogin: lastLogin);

  factory Etudiant.fromApi(dynamic data) {
    if (data is int) {
      return new Etudiant(id: data);
    }
    if (data is Map<String, dynamic>) {
      return Etudiant.fromJson(data);
    }
    throw new Exception('Invalid format');
  }

  factory Etudiant.fromJson(Map<String, dynamic> json) => new Etudiant(
    id: json["id"],
    username: json["username"],
    firstname: json["first_name"],
    lastname: json["last_name"],
    lastLogin: json["last_login"] == null ? null : DateTime.parse(json["last_login"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "role": User.ETUDIANT,
    "username": username,
    "first_name": firstname,
    "lastname": lastname,
    "last_login": lastLogin == null ? null : lastLogin,
  };
}