import 'dart:core';

class AbsenceSeance {
  int id;
  bool absent;
  int retard;
  String justification;

  AbsenceSeance({
    this.id,
    this.absent,
    this.retard,
    this.justification,
  });

  String typeAbsence() {
    if(this.absent) return "Absence";
    return "Retard";
  }

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
    absent: json["absent"],
    retard: json["retard"],
    justification: json["justification"],
  );

  Map<String, dynamic> toJson({bool forApi = true}) => {
    "id": id,
    "absent": absent,
    "retard": retard,
    "justification": justification,
  };
}