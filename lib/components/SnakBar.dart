import 'package:flutter/material.dart';

void showSuccessMessage(context, String message) {
  final snackBar = SnackBar(
    content: Text(
      message,
      style: TextStyle(color: Colors.white),
    ),
    backgroundColor: message == "Success" ? Colors.green : Colors.red,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
