import 'package:flutter/material.dart';

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
  }); /*{
    if (dateStart == null) dateStart = new DateTime.now();
    if (dateEnd == null) dateEnd = new DateTime.now().add(new Duration(hours: 2));
  }

  set startAt(TimeOfDay startAt) {
    final now = new DateTime.now();
    dateStart = new DateTime(now.year, now.month, now.day, startAt.hour, startAt.minute);
  }
  TimeOfDay get startAt => dateStart == null ? null : new TimeOfDay(hour: dateStart.hour, minute: dateStart.minute);

  set endAt(TimeOfDay endAt) {
    final now = new DateTime.now();
    dateEnd = new DateTime(now.year, now.month, now.day, endAt.hour, endAt.minute);
  }
  TimeOfDay get endAt => dateEnd == null ? null : new TimeOfDay(hour: dateEnd.hour, minute: dateEnd.minute);

  Duration get diff {
    return dateEnd.difference(dateStart);
  }

  bool get isPassed => dateEnd == null ? null : dateEnd.isBefore(new DateTime.now());*/

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
    dateSeance: json["date_seance"].toString().substring(0,json["date_seance"].toString().indexOf("T")),
    dateStart: json["heure_deb"].toString().substring(0,5),
    dateEnd: json["heure_fin"].toString().substring(0,5),
  );

  Map<String, dynamic> toJson({bool forApi = true}) => {
    "id": id,
    "date_seance": dateStart,
    "heure_deb": dateStart,
    "heure_fin": dateEnd,
  };
}
