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

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
    loadData();
  }

  loadData() async {
    notesList = dbHelper!.getNotesList();
  }

  void _showNoteBottomSheet(BuildContext context, {NotesModel? note}) {
    if (note != null) {
      _titleController.text = note.title;
      _descriptionController.text = note.dscription;
    } else {
      _titleController.clear();
      _descriptionController.clear();
    }

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                  errorText: _titleController.text.isEmpty ? 'Title is required' : null,
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  errorText: _descriptionController.text.isEmpty ? 'Description is required' : null,
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
                        setState(() {});
                      } else {
                        final date = DateTime.now().toString().split(' ')[0]; // Only date
                        if (note != null) {
                          dbHelper!
                              .update(NotesModel(
                            id: note.id,
                            title: _titleController.text,
                            dscription: _descriptionController.text,
                            date: date,
                          ))
                              .then((value) {
                            setState(() {
                              notesList = dbHelper!.getNotesList();
                            });
                            Navigator.pop(context);
                          });
                        } else {
                          dbHelper!
                              .insert(NotesModel(
                            title: _titleController.text,
                            dscription: _descriptionController.text,
                            date: date,
                          ))
                              .then((value) {
                            setState(() {
                              notesList = dbHelper!.getNotesList();
                            });
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Note successfully added!'),
                            ));
                            Navigator.pop(context);
                          });
                        }
                      }
                    },
                    child: Text(note != null ? 'Update' : 'Add'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Cancel'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
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
              builder: (context, AsyncSnapshot<List<NotesModel>> snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data?.length,
                    itemBuilder: (context, index) {
                      return Dismissible(
                        key: ValueKey<int>(snapshot.data![index].id!),
                        background: Container(
                          color: Colors.redAccent,
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 20),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          dbHelper!.delete(snapshot.data![index].id!).then((value) {
                            setState(() {
                              notesList = dbHelper!.getNotesList();
                            });
                          });
                        },
                        child: InkWell(
                          onTap: () {
                            _showNoteBottomSheet(context, note: snapshot.data![index]);
                          },
                          child: Card(
                            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    snapshot.data![index].title.toString(),
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    snapshot.data![index].dscription.toString(),
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    snapshot.data![index].date,
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showNoteBottomSheet(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
