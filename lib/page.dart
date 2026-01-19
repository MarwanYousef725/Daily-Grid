// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart'
//     show SharedPreferences;

// class Task {
//   final int number;
//   final DateTime date;
//   bool isDone;

//   Task({required this.number, required this.date, this.isDone = false});

//   Map<String, dynamic> toJson() => {
//     'number': number,
//     'DateTime': date.toIso8601String(),
//     'isDone': isDone,
//   };

//   factory Task.fromJson(json) => Task(
//     number: json['number'],
//     date: DateTime.parse(json['DateTime']),
//     isDone: json['isDone'] ?? false,
//   );
// }

// class Page extends StatefulWidget {
//   const Page({super.key});

//   @override
//   State<Page> createState() => _PageState();
// }

// class _PageState extends State<Page> {
//   List<Task> tasks = [];
//   @override
//   void initState() {
//     super.initState();
//     _initialize();
//   }

//   Future<void> _initialize() async {
//     await loadTasks();
//   }

//   Future<void> saveTasks() async {
//     SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
//     for (int i = 0; i < tasks.length; i++) {
//       final jsonList = tasks.map((t) => jsonEncode(t.toJson())).toList();
//       await sharedPreferences.setStringList('tasks', jsonList);
//     }
//   }

//   Future<void> loadTasks() async {
//     final prefs = await SharedPreferences.getInstance();
//     for (int i = 0; i < tasks.length; i++) {
//       final jsonList = prefs.getStringList('tasks') ?? [];
//       setState(() {
//         tasks = jsonList.map((s) => Task.fromJson(jsonDecode(s))).toList();
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return;
//   }
// }
