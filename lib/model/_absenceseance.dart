import 'dart:core';

import 'package:heimdall/model/_absence.dart';
import 'package:heimdall/model/_seance.dart';

class AbsenceSeance {
  int id;
  Absence absence;
  Seance seance;

  AbsenceSeance({
    this.id,
    this.absence,
    this.seance,
  });

  factory AbsenceSeance.fromApi(dynamic data) {
    if (data is int) {
      return new AbsenceSeance(id: data);
    }
    if (data is Map<String, dynamic>) {
      return AbsenceSeance.fromJson(data);
    }
    throw new Exception('Invalid format');
  }

  factory AbsenceSeance.fromJson(Map<String, dynamic> json) => new AbsenceSeance(
    id: json["id"],
    seance: json["seance"] == null ? null : Seance.fromApi(json["seance"]),
    absence: json["absence_seance"] == null ? null : Absence.fromApi(json["absence_seance"]),
  );

  Map<String, dynamic> toJson({bool forApi = true}) => {
    "id": id,
    "seance": seance == null ? null : seance.toJson(),
    "absence_seance": forApi ? absence.id : absence.toJson(),
  };
}