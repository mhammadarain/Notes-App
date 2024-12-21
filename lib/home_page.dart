import 'package:flutter/material.dart';
import 'package:notes_sqlite/db_handler.dart';

import 'notes.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  DBHelper? dbHelper;
  late Future<List<NotesModel>> notesList;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dbHelper = DBHelper();
    loadData();
  }

  loadData ()async{
    notesList = dbHelper!.getNotesList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notes"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: notesList,
                builder:(context,AsyncSnapshot<List<NotesModel>> snaphsot){

                if(snaphsot.hasData){
                  return ListView.builder(
                    //reverse: true,
                      itemCount: snaphsot.data?.length,
                      itemBuilder: (context,index){
                        return InkWell(
                          onTap: (){
                            dbHelper!.update(NotesModel(
                              id: snaphsot.data![index].id,
                                title: "Updeted Note",
                                email: "arain@gmail.com",
                                dscription: " This is updated note here",
                                age: 24)
                            );
                            setState(() {
                              notesList = dbHelper!.getNotesList();
                            });
                          },
                          child: Dismissible(
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.redAccent,
                              child: Icon(Icons.delete_forever_rounded),
                            ),
                            onDismissed: (DismissDirection direction){
                              setState(() {
                                dbHelper!.delete(snaphsot.data![index].id!);
                                notesList = dbHelper!.getNotesList();
                                snaphsot.data!.remove(snaphsot.data![index]);
                              });
                            },
                            key: ValueKey<int>(snaphsot.data![index].id!) ,
                            child: Card(
                              child: ListTile(
                                contentPadding: EdgeInsets.all(0),
                                title: Text(snaphsot.data![index].title.toString()),
                                subtitle: Text(snaphsot.data![index].dscription.toString()),
                                trailing: Text(snaphsot.data![index].age.toString()),
                              ),
                            ),
                          ),
                        );
                      });
                }else{
                  return CircularProgressIndicator();
                }

              }
              ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          dbHelper!.insert(
            NotesModel(
              title: "Second Note",
              age: 22,
                dscription: "This is my Second sql app",
              email:  "mhammad@gmail.com"
            )
          ).then((value){
            print("data added");
            setState(() {
              notesList = dbHelper!.getNotesList();
            });
          }).onError((error, stackTrace){
            print(error.toString());
          });

        },
        child: Icon(Icons.add),
      ),
    );
  }
}
