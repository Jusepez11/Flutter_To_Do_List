import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To Do List',
      theme: ThemeData(

        colorScheme: ColorScheme.dark(),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'To Do List'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class TodoItem {
  String title;
  bool isSelected;

  TodoItem(this.title, {this.isSelected = false});

  String toJson() {
    return '{"title": "$title", "isSelected": $isSelected}';
  }

  factory TodoItem.fromJson(String json) {
    final Map<String, dynamic> data = jsonDecode(json);
    return TodoItem(
      data['title'],
      isSelected: data['isSelected'],
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  List<TodoItem> _todoItems = [];

  @override
  void initState() {
    super.initState();
    _loadTodoItems();
  }

  Future<void> _saveTodoItems() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> todoList = _todoItems.map((item) => item.toJson()).toList();
    await prefs.setStringList('todoItems', todoList);
  }

  Future<void> _loadTodoItems() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? todoList = prefs.getStringList('todoItems');
    if (todoList != null) {
      setState(() {
        _todoItems = todoList.map((item) => TodoItem.fromJson(item)).toList();
      });
    }
  }

  void _addTask() {
    if (_controller.text == "")return;
    setState(() {
      _todoItems.add(TodoItem(_controller.text));
      _controller.clear();
      _saveTodoItems();
    });
  }

  void _toggleSelection(int index) {
    setState(() {
      _todoItems[index].isSelected = !_todoItems[index].isSelected;
      _saveTodoItems();
    });
  }

  void _deleteTask(int index){
    setState(() {
      _todoItems.removeAt(index);
      _saveTodoItems();
    });
  }

  void _editTask(int index) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController editController = TextEditingController();
        editController.text = _todoItems[index].title;

        return AlertDialog(
          title: const Text('Edit Task'),
          content: TextField(
            controller: editController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Task Title',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _todoItems[index].title = editController.text;
                  _saveTodoItems();
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter Task',
                ),
                  onSubmitted: (value) {
                    _addTask();
                  }
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _todoItems.length,
                itemBuilder: (context, index) {
                  final item = _todoItems[index];
                  return ListTile(
                    title: Text(item.title),
                    tileColor: item.isSelected ? Colors.grey[300] : null,
                    onTap: () => _toggleSelection(index),
                    trailing: Row(
                    mainAxisSize: MainAxisSize.min, // Ensure the row takes up only as much space as needed
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editTask(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteTask(index),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        tooltip: 'Add task to list',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}