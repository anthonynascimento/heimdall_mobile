import 'dart:core';

class Absence {
  int id;
  bool absent;
  int retard;
  String justification;

  Absence({
    this.id,
    this.absent,
    this.retard,
    this.justification,
  });

  String typeAbsence() {
    if(this.absent) return "Absence";
    return "Retard";
  }

  factory Absence.fromApi(dynamic data) {
    if (data is int) {
      return new Absence(id: data);
    }
    if (data is Map<String, dynamic>) {
      return Absence.fromJson(data);
    }
    throw new Exception('Invalid format');
  }

  factory Absence.fromJson(Map<String, dynamic> json) => new Absence(
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