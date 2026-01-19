import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Task {
  final int number;
  final DateTime date;
  bool isDone;

  Task({required this.number, required this.date, this.isDone = false});

  Map<String, dynamic> toJson() => {
    'number': number,
    'DateTime': date.toIso8601String(),
    'isDone': isDone,
  };

  factory Task.fromJson(json) => Task(
    number: json['number'],
    date: DateTime.parse(json['DateTime']),
    isDone: json['isDone'] ?? false,
  );
}

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  List<Task> tasks = [];
  List pageViewList = [];
  late TextEditingController numberController;
  late TextEditingController dateController;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool numberenable = false;
  @override
  void initState() {
    super.initState();
    numberController = TextEditingController();
    dateController = TextEditingController();
    _initialize();
  }

  Future<void> _initialize() async {
    await loadTasks();
  }

  Future<void> saveTasks() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final jsonList = tasks.map((t) => jsonEncode(t.toJson())).toList();
    await sharedPreferences.setStringList('tasks', jsonList);
    pageViewList.add(jsonList);
    print('=============================================');
    print(pageViewList);
    print('=============================================');
  }

  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList('tasks') ?? [];
    setState(() {
      tasks = jsonList.map((s) => Task.fromJson(jsonDecode(s))).toList();
    });
  }

  late BuildContext scaffoldContext;
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (ctx) {
        scaffoldContext = ctx;

        return PageView.builder(
          itemCount: pageViewList.length,
          itemBuilder: (context, i) {
            return Scaffold(
              appBar: AppBar(
                title: const Text(
                  'Daily Grid',
                  style: TextStyle(color: Colors.white),
                ),
                actions: [
                  IconButton(
                    onPressed: () {
                      // setState(() {
                      //   tasks.add(Center(child: Text('data')));
                      // });
                    },
                    icon: Icon(Icons.add),
                    iconSize: 30,
                    padding: EdgeInsets.only(left: 20, right: 20),
                    color: Colors.white,
                  ),
                ],
                backgroundColor: Colors.white60,
              ),
              backgroundColor: const Color.fromARGB(255, 33, 33, 33),
              floatingActionButton: FloatingActionButton(
                backgroundColor: const Color.fromARGB(255, 50, 50, 50),
                onPressed: () {
                  showDialog(
                    barrierDismissible: false,
                    barrierColor: Color.fromARGB(220, 0, 0, 0),
                    context: context,
                    builder: (context) {
                      return StatefulBuilder(
                        builder: (context, setsta) {
                          return AlertDialog(
                            backgroundColor: Color.fromARGB(255, 50, 50, 50),
                            title: const Text(
                              'Add Tasks',
                              style: TextStyle(color: Colors.white),
                            ),
                            content: SizedBox(
                              height: 150,
                              width: 300,
                              child: Column(
                                children: [
                                  TextField(
                                    onTapOutside: (event) {
                                      FocusScope.of(context).unfocus();
                                    },
                                    onChanged: (value) {
                                      setsta(() {
                                        numberenable = value.isNotEmpty;
                                      });
                                    },
                                    controller: numberController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: "Enter number of cards",
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(
                                          100,
                                        ),
                                      ),
                                      fillColor: Colors.grey[200],
                                      filled: true,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  TextField(
                                    onTapOutside: (event) {
                                      FocusScope.of(context).unfocus();
                                    },
                                    controller: dateController,
                                    keyboardType: TextInputType.datetime,
                                    decoration: InputDecoration(
                                      hintText: "Enter Date (dd/MM/yyyy)",
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      fillColor: Colors.grey[200],
                                      filled: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            actionsAlignment: MainAxisAlignment.spaceEvenly,
                            actions: [
                              TextButton(
                                onPressed: numberenable
                                    ? () async {
                                        Navigator.of(context).pop();
                                        setState(() {
                                          List date;
                                          if (dateController.text.isNotEmpty) {
                                            date = dateController.text.split(
                                              '/',
                                            );
                                          } else {
                                            date = DateFormat('dd/MM/yyyy')
                                                .format(DateTime.now())
                                                .toString()
                                                .split('/');
                                          }
                                          int year;
                                          int month;
                                          int day;
                                          try {
                                            year = int.parse(date[2]);
                                            month = int.parse(date[1]);
                                            day = int.parse(date[0]);
                                            tasks.clear();
                                            int number =
                                                int.tryParse(
                                                  numberController.text
                                                      .toString(),
                                                ) ??
                                                0;
                                            for (int i = 1; i <= number; i++) {
                                              tasks.add(
                                                Task(
                                                  number: i,
                                                  date: DateTime(
                                                    year,
                                                    month,
                                                    day,
                                                  ).add(Duration(days: i - 1)),
                                                ),
                                              );
                                            }
                                          } catch (e) {
                                            ScaffoldMessenger.of(
                                              scaffoldContext,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Invalid Date (dd/MM/yyyy)",
                                                ),
                                              ),
                                            );
                                          }
                                        });
                                        await saveTasks();
                                        numberController.text = '';
                                        dateController.text = '';
                                        setState(() {
                                          numberenable = false;
                                        });
                                      }
                                    : null,
                                style: TextButton.styleFrom(
                                  backgroundColor: Color.fromARGB(
                                    255,
                                    33,
                                    33,
                                    33,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  disabledBackgroundColor: Color.fromARGB(
                                    100,
                                    33,
                                    33,
                                    33,
                                  ),
                                ),
                                child: Text(
                                  'OK',
                                  style: TextStyle(
                                    color: numberenable
                                        ? Colors.white
                                        : Color.fromARGB(105, 255, 255, 255),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  numberController.text = '';
                                  dateController.text = '';
                                  setState(() {
                                    numberenable = false;
                                  });
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: Color.fromARGB(
                                    255,
                                    33,
                                    33,
                                    33,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
                child: const Icon(Icons.add, color: Colors.white),
              ),
              body: SafeArea(
                child: pageViewList[i].isNotEmpty
                    ? GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisExtent: 100,
                            ),
                        itemCount: pageViewList[i].length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () async {
                              setState(() {
                                pageViewList[i][index].isDone =
                                    !tasks[index].isDone;
                              });
                              await saveTasks();
                            },
                            child: Card(
                              color: pageViewList[i][index].isDone
                                  ? const Color.fromARGB(255, 20, 71, 23)
                                  : const Color.fromARGB(255, 80, 80, 80),
                              child: Center(
                                child: pageViewList[i][index].isDone
                                    ? const Icon(
                                        Icons.task_alt_outlined,
                                        color: Colors.green,
                                        size: 50,
                                      )
                                    : ListTile(
                                        title: Text(
                                          '${pageViewList[i][index].number}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 25,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        subtitle: Text(
                                          DateFormat(
                                            'dd/MM/yyyy',
                                          ).format(tasks[index].date),
                                          style: const TextStyle(
                                            color: Colors.white54,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          );
                        },
                      )
                    : const Center(
                        child: Text(
                          'No Daily Grid',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
              ),
            );
          },
        );
      },
    );
  }
}
