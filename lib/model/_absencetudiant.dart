import 'dart:core';

import 'package:heimdall/model/_absenceseance.dart';
import 'package:heimdall/model/_seance.dart';

class AbsenceEtudiant {
  int id;
  AbsenceSeance absence;
  Seance seance;

  AbsenceEtudiant({
    this.id,
    this.absence,
    this.seance,
  });

  factory AbsenceEtudiant.fromApi(dynamic data) {
    if (data is int) {
      return new AbsenceEtudiant(id: data);
    }
    if (data is Map<String, dynamic>) {
      return AbsenceEtudiant.fromJson(data);
    }
    throw new Exception('Invalid format');
  }

  factory AbsenceEtudiant.fromJson(Map<String, dynamic> json) => new AbsenceEtudiant(
    id: json["id"],
    seance: json["seance"] == null ? null : Seance.fromApi(json["seance"]),
    absence: json["absence_seance"] == null ? null : AbsenceSeance.fromApi(json["absence_seance"]),
  );

  Map<String, dynamic> toJson({bool forApi = true}) => {
    "id": id,
    "seance": seance == null ? null : seance.toJson(),
    "absence_seance": forApi ? absence.id : absence.toJson(),
  };
}