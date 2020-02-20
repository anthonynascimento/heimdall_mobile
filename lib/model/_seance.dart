import 'package:heimdall/model/_matiere.dart';
import 'package:heimdall/model/class_group.dart';

class Seance {
  int id;
  String dateSeance;
  String dateStart;
  String dateEnd;

  Seance({
    this.id,
    this.dateSeance,
    this.dateStart,
    this.dateEnd,
  });
  

  String dateBonFormat() {
    List<String> liste = this.dateSeance.split('-');
    return liste[2]+'/'+liste[1]+'/'+liste[0];
  }

  String heureDebBonFormat() {
    return this.dateStart.substring(0,5);
  }

  String heureFinBonFormat() {
    return this.dateEnd.substring(0,5);
  }

  factory Seance.fromApi(dynamic data) {
    if (data is int) {
      return new Seance(id: data);
    }
    if (data is Map<String, dynamic>) {
      return Seance.fromJson(data);
    }
    throw new Exception('Invalid format');
  }

  factory Seance.fromJson(Map<String, dynamic> json) => new Seance(
    id: json["id"],
    dateSeance: json["date_seance"],
    dateStart: json["heure_deb"].toString(),
    dateEnd: json["heure_fin"].toString()
  );

  Map<String, dynamic> toJson({bool forApi = true}) => {
    "id": id,
    "date_seance": dateStart,
    "heure_deb": dateStart,
    "heure_fin": dateEnd,
  };
}
