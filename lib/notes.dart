

class NotesModel{

  final int? id;
  final String title;
  final int age;
  final String dscription;
  final String email;

  NotesModel({this.id, required this.title, required this.email, required this.dscription, required this.age});

  NotesModel.fromMap(Map<String, dynamic> res):
      id = res["id"],
      title  = res["title"],
  age = res["age"],
        dscription = res["dscription"],
  email = res["email"];

  Map<String, Object?> toMap(){
    return {
      "id": id,
      "title": title,
      "age":age,
    "dscription": dscription,
      "email": email,
    };
  }


}