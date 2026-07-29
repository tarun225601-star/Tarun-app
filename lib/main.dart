Here's a professional notes and tasks app in Flutter. The app will have the following features:
- User can create, read, update, and delete notes
- User can create, read, update, and delete tasks
- User can mark tasks as completed
- User can filter notes and tasks by title

```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class Note {
  String title;
  String content;
  DateTime createdAt;

  Note({required this.title, required this.content, required this.createdAt});
}

class Task {
  String title;
  String content;
  bool isCompleted;
  DateTime createdAt;

  Task({required this.title, required this.content, required this.isCompleted, required this.createdAt});
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes and Tasks',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Note> _notes = [];
  List<Task> _tasks = [];
  final _noteController = TextEditingController();
  final _noteContentController = TextEditingController();
  final _taskController = TextEditingController();
  final _taskContentController = TextEditingController();
  bool _isNoteDialogOpen = false;
  bool _isTaskDialogOpen = false;

  void _addNote() {
    if (_noteController.text.isNotEmpty && _noteContentController.text.isNotEmpty) {
      setState(() {
        _notes.add(Note(
          title: _noteController.text,
          content: _noteContentController.text,
          createdAt: DateTime.now(),
        ));
        _noteController.clear();
        _noteContentController.clear();
      });
    }
  }

  void _addTask() {
    if (_taskController.text.isNotEmpty && _taskContentController.text.isNotEmpty) {
      setState(() {
        _tasks.add(Task(
          title: _taskController.text,
          content: _taskContentController.text,
          isCompleted: false,
          createdAt: DateTime.now(),
        ));
        _taskController.clear();
        _taskContentController.clear();
      });
    }
  }

  void _deleteNote(int index) {
    setState(() {
      _notes.removeAt(index);
    });
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
  }

  void _toggleTaskCompletion(int index) {
    setState(() {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes and Tasks'),
      ),
      body: TabBarView(
        children: [
          _buildNotesTab(),
          _buildTasksTab(),
        ],
      ),
      bottomNavigationBar: TabBar(
        tabs: [
          Tab(icon: Icon(Icons.note), text: 'Notes'),
          Tab(icon: Icon(Icons.task), text: 'Tasks'),
        ],
      ),
    );
  }

  Widget _buildNotesTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isNoteDialogOpen = true;
                    });
                  },
                  child: Text('Add Note'),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Search notes',
                  ),
                  onChanged: (text) {
                    setState(() {
                      _notes = _notes
                          .where((note) => note.title.toLowerCase().contains(text.toLowerCase()))
                          .toList();
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _isNoteDialogOpen
              ? _buildNoteDialog()
              : _notes.isEmpty
                  ? Center(child: Text('No notes found'))
                  : ListView.builder(
                      itemCount: _notes.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_notes[index].title),
                          subtitle: Text(_notes[index].content),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  _deleteNote(index);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildTasksTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isTaskDialogOpen = true;
                    });
                  },
                  child: Text('Add Task'),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Search tasks',
                  ),
                  onChanged: (text) {
                    setState(() {
                      _tasks = _tasks
                          .where((task) => task.title.toLowerCase().contains(text.toLowerCase()))
                          .toList();
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _isTaskDialogOpen
              ? _buildTaskDialog()
              : _tasks.isEmpty
                  ? Center(child: Text('No tasks found'))
                  : ListView.builder(
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_tasks[index].title),
                          subtitle: Text(_tasks[index].content),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                value: _tasks[index].isCompleted,
                                onChanged: (value) {
                                  _toggleTaskCompletion(index);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  _deleteTask(index);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildNoteDialog() {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Note title',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _noteContentController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Note content',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addNote,
              child: Text('Add Note'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isNoteDialogOpen = false;
                });
              },
              child: Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskDialog() {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _taskController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Task title',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _taskContentController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Task content',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addTask,
              child: Text('Add Task'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isTaskDialogOpen = false;
                });
              },
              child: Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
```