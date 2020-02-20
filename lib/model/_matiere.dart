class Matiere {
  int id;
  String nom;

  Matiere({
    this.id,
    this.nom,
  });
  

  factory Matiere.fromApi(dynamic data) {
    if (data is int) {
      return new Matiere(id: data);
    }
    if (data is Map<String, dynamic>) {
      return Matiere.fromJson(data);
    }
    throw new Exception('Invalid format');
  }

  factory Matiere.fromJson(Map<String, dynamic> json) => new Matiere(
    id: json["id"],
    nom: json["nom"],
  );

  Map<String, dynamic> toJson({bool forApi = true}) => {
    "id": id,
    "nom": nom,
  };
}
