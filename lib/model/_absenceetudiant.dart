import 'dart:core';

import 'package:heimdall/model/_absence.dart';
import 'package:heimdall/model/_seance.dart';
import 'package:heimdall/model/etudiant.dart';

class AbsenceEtudiant {
  int id;
  Absence absence;
  Etudiant etudiant;

  AbsenceEtudiant({
    this.id,
    this.absence,
    this.etudiant,
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
    etudiant: json["etudiant"] == null ? null : Etudiant.fromApi(json["etudiant"]["user"]),
    absence: json["absence_etudiant"] == null ? null : Absence.fromApi(json["absence_etudiant"]),
  );

  Map<String, dynamic> toJson({bool forApi = true}) => {
    "id": id,
    "etudiant": etudiant == null ? null : etudiant.toJson(),
    "absence_etudiant": forApi ? absence.id : absence.toJson(),
  };
}