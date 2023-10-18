import 'dart:convert';

import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
import 'package:todo/utils/config.dart';

class AddTodo extends StatefulWidget {
  final Map? todo;

  const AddTodo({super.key, this.todo});

  @override
  State<AddTodo> createState() => _AddTodoState();
}

class _AddTodoState extends State<AddTodo> {
  TextEditingController titleController = TextEditingController();
  TextEditingController desController = TextEditingController();
  bool isEdit = false;
  @override
  void initState() {
    super.initState();
    final todo = widget.todo;
    if (todo != null) {
      isEdit = true;
      final title = todo['title'];
      final des = todo['description'];
      titleController.text = title;
      desController.text = des;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit" : "Add todo"),
      ),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        TextField(
          decoration: const InputDecoration(hintText: "Title"),
          controller: titleController,
        ),
        const SizedBox(
          height: 20,
        ),
        TextField(
          controller: desController,
          decoration: const InputDecoration(hintText: "Description"),
          keyboardType: TextInputType.multiline,
          minLines: 1,
          maxLines: 8,
        ),
        const SizedBox(
          height: 20,
        ),
        ElevatedButton(
            onPressed: () {
              if (!isEdit) {
                submitData();
              } else {
                updateData();
              }
            },
            child: const Text("Submit"))
      ]),
    );
  }

  Future<void> updateData() async {
    final todo = widget.todo;
    if (todo == null) {
      print("you can not update without data");
      return null;
    }
    final id = todo['_id'];
    final isCompleted = todo['is_completed'];
    final title = titleController.text;
    final des = desController.text;
    final uri = Uri.parse("$url/api/todos/$id");
    final body = {
      "title": title,
      "description": des,
      "is_completed": isCompleted,
    };
    print(body);

    final response = await http.put(uri, body: jsonEncode(body), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      "Authorization": token.toString()
    });
    print(response.body);
    print(response.statusCode);
    if (response.statusCode == 200) {
      showSuccessMessage("Update Success", true);
      titleController.text = "";
      desController.text = "";
    } else {
      showSuccessMessage("Update Failed", false);
    }
  }

  Future<void> submitData() async {
    final title = titleController.text;
    final des = desController.text;
    final uri = Uri.parse("$url/api/todos");
    final body = {
      "title": title,
      "description": des,
      "is_completed": false,
    };
    final response = await http.post(uri, body: jsonEncode(body), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      "Authorization": token.toString()
    });
    print(response.statusCode);
    if (response.statusCode == 201) {
      showSuccessMessage("Success", true);
      titleController.text = "";
      desController.text = "";
    } else {
      showSuccessMessage("Failed", false);
    }
  }

  void showSuccessMessage(String message, bool isSuccess) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: isSuccess ? Colors.green : Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
