class NotesModel {
  final int? id;
  final String title;
  final String dscription;
  final String date;

  NotesModel({
    this.id,
    required this.title,
    required this.dscription,
    required this.date,
  });

  NotesModel.fromMap(Map<String, dynamic> res)
      : id = res["id"],
        title = res["title"],
        dscription = res["dscription"],
        date = res["date"];

  Map<String, Object?> toMap() {
    return {
      "id": id,
      "title": title,
      "dscription": dscription,
      "date": date,
    };
  }
}
