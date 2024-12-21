import 'dart:io';

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

  bool _isTitleValid = true; // Validation state for title
  bool _isDescriptionValid = true; // Validation state for description
  String _errorMessage = ''; // Error message to show

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
    setState(() {
      _isTitleValid = true; // Reset validation state for title
      _isDescriptionValid = true; // Reset validation state for description
      _errorMessage = ''; // Reset error message
    });

    if (note != null) {
      _titleController.text = note.title;
      _descriptionController.text = note.dscription;
    } else {
      _titleController.clear();
      _descriptionController.clear();
    }

    final _formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.95,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Display the error message if validation fails
                  if (!_isTitleValid || !_isDescriptionValid)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        _errorMessage,
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ),
                  // Title TextField
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: _isTitleValid ? Colors.blue : Colors.red, // Change color based on validation
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Title is required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  // Description TextField
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: _isDescriptionValid ? Colors.blue : Colors.red, // Change color based on validation
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Description is required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Cancel'),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _isTitleValid = _titleController.text.trim().isNotEmpty;
                              _isDescriptionValid = _descriptionController.text.trim().isNotEmpty;
                              // Set error message based on the validation result
                              _errorMessage = _isTitleValid && _isDescriptionValid
                                  ? ''
                                  : 'Both Title and Description are required';
                            });

                            // If both fields are valid, proceed with the add or update
                            if (_isTitleValid && _isDescriptionValid) {
                              final date = DateTime.now().toString().split(' ')[0]; // Get only the date
                              if (note != null) {
                                // Update existing note
                                dbHelper!
                                    .update(
                                  NotesModel(
                                    id: note.id,
                                    title: _titleController.text.trim(),
                                    dscription: _descriptionController.text.trim(),
                                    date: date,
                                  ),
                                )
                                    .then((value) {
                                  setState(() {
                                    notesList = dbHelper!.getNotesList();
                                  });
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Note successfully updated!'),
                                    ),
                                  );
                                }).catchError((error) {
                                  print('Error updating note: $error');
                                });
                              } else {
                                // Insert new note
                                dbHelper!
                                    .insert(
                                  NotesModel(
                                    title: _titleController.text.trim(),
                                    dscription: _descriptionController.text.trim(),
                                    date: date,
                                  ),
                                )
                                    .then((value) {
                                  setState(() {
                                    notesList = dbHelper!.getNotesList(); // Refresh the notes list
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Note successfully added!'),
                                    ),
                                  );
                                  Navigator.pop(context); // Close the bottom sheet
                                }).catchError((error) {
                                  print('Error adding note: $error');
                                });
                              }
                            }
                          },
                          child: Text(note != null ? 'Update' : 'Add'),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        backgroundColor: Colors.blue[50],
        title: Padding(
          padding: const EdgeInsets.only(top: 30),
          child: Text(
            "Notes",
            style: TextStyle(fontSize: 33),
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
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
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.redAccent,
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 20),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          int noteId = snapshot.data![index].id!;
                          dbHelper!.delete(noteId).then((value) {
                            setState(() {
                              snapshot.data!.removeAt(index); // Remove item from list
                            });
                          });
                        },
                        child: InkWell(
                          onTap: () {
                            _showNoteBottomSheet(context, note: snapshot.data![index]);
                          },
                          child: Card(
                            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            child: Container(
                              width: double.infinity,
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
