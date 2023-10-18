import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:todo/screens/add_todo_screen.dart';
import "package:http/http.dart" as http;
import 'package:todo/utils/config.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = true;
  List items = [];
  @override
  void initState() {
    super.initState();
    getTodoList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Todo list"),
      ),
      body: Visibility(
        visible: isLoading,
        child: Center(
          child: CircularProgressIndicator(),
        ),
        replacement: RefreshIndicator(
          onRefresh: getTodoList,
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: ((context, index) {
              final item = items[index];
              final id = item["_id"] as String;
              // final id = "8";
              return ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text(item['title']),
                subtitle: Text(item['description']),
                trailing: PopupMenuButton(onSelected: (value) {
                  if (value == 'delete') {
                    deleteItem(id);
                  } else {
                    navigateToEditTodo(item);
                  }
                }, itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      child: Text("Edit"),
                      value: 'edit',
                    ),
                    PopupMenuItem(
                      child: Text("Delete"),
                      value: 'delete',
                    )
                  ];
                }),
              );
            }),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: navigateToAddTodo, label: Text("Add todo")),
    );
  }

  Future<void> navigateToEditTodo(Map item) async {
    final route = MaterialPageRoute(
        builder: (context) => AddTodo(
              todo: item,
            ));
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    getTodoList();
  }

  Future<void> navigateToAddTodo() async {
    final route = MaterialPageRoute(builder: (context) => AddTodo());
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    getTodoList();
  }

  void showSuccessMessage(String message, bool error) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: !error ? Color.fromARGB(255, 84, 211, 135) : Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> deleteItem(String id) async {
    final uri = Uri.parse('$url/api/todos/$id');
    print(uri);
    final response = await http.delete(uri, headers: {
      // 'Content-Type': 'application/json',
      // 'Accept': 'application/json',
      "Authorization": token.toString()
    });
    print(response);
    if (response.statusCode == 200) {
      showSuccessMessage("Deleted", false);
      final filtered = items.where((element) => element['_id'] != id).toList();
      setState(() {
        items = filtered;
      });
    } else {}
  }

  Future<void> getTodoList() async {
    final uri = Uri.parse('$url/api/todos');
    final response = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      "Authorization": token.toString()
    });
    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      // final result = json['items'];
      setState(() {
        items = json;
      });
    } else if (response.statusCode == 429) {
      showSuccessMessage("Too many requests", true);
    } else {
      print("error");
      showSuccessMessage("Something went wrong", true);
    }

    setState(() {
      isLoading = false;
    });
  }
}
