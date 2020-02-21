class Matiere {
  int id;
  String titre;

  Matiere({
    this.id,
    this.titre,
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
    titre: json["titre"],
  );

  Map<String, dynamic> toJson({bool forApi = true}) => {
    "id": id,
    "titre": titre,
  };
}
