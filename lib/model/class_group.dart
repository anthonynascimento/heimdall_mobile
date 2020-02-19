import 'package:heimdall/model/RollCall.dart';
import 'package:heimdall/model/etudiant.dart';
import 'package:heimdall/model/professeur.dart';

class ClassGroup {
  int id;
  String nompromotion;
  String statuspromotion;
  String anneefiliere;

  ClassGroup({
    this.id,
    this.nompromotion,
    this.statuspromotion,
    this.anneefiliere
  });

  factory ClassGroup.fromApi(dynamic data) {
    if (data is int) {
      return new ClassGroup(id: data);
    }
    if (data is Map<String, dynamic>) {
      return ClassGroup.fromJson(data);
    }
    throw new Exception('Invalid format');
  }

  factory ClassGroup.fromJson(Map<String, dynamic> json) => new ClassGroup(
    id: json["id"],
    nompromotion: json["nom_promotion"],
    statuspromotion: json["status_promotion"],
    anneefiliere: json["annee_filiere"],
   
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "nom_promotion": nompromotion,
    "status_promotion": statuspromotion,
    "annee_filiere": anneefiliere
    
  };
}
