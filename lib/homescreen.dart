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

class _HomescreenState extends State<Homescreen> with TickerProviderStateMixin {
  List<Map<String, dynamic>> tabbar = [
    {'name': 'Default', 'tasks': <Task>[]},
  ];

  int lengths = 1;
  late TabController tabController;
  late ScrollController scrollController;
  late TextEditingController numberController;
  late TextEditingController nameController;
  late TextEditingController updatenameController;
  late TextEditingController dateController;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  GlobalKey<FormState> updateFormKey = GlobalKey<FormState>();
  bool numberenable = false;
  late BuildContext scaffoldContext;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    numberController = TextEditingController();
    dateController = TextEditingController();
    nameController = TextEditingController();
    updatenameController = TextEditingController();
    tabController = TabController(length: lengths, vsync: this);
    _initialize();
  }

  Future<void> _initialize() async {
    await loadTasks();
  }

  Future<void> saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final jsonList = tabbar.map((tab) {
      return jsonEncode({
        'name': tab['name'],
        'tasks': (tab['tasks'] as List<Task>).map((t) => t.toJson()).toList(),
      });
    }).toList();
    await prefs.setStringList('tabbar', jsonList);
  }

  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList('tabbar') ?? [];

    List<Map<String, dynamic>> loaded = [];
    try {
      loaded = jsonList.map((s) {
        final decoded = jsonDecode(s);
        return {
          'name': decoded['name'],
          'tasks': (decoded['tasks'] as List<dynamic>)
              .map((e) => Task.fromJson(e))
              .toList(),
        };
      }).toList();
    } catch (e) {
      loaded = [];
    }

    setState(() {
      tabbar = loaded.isNotEmpty
          ? loaded
          : [
              {'name': 'Default', 'tasks': <Task>[]},
            ];
      lengths = tabbar.length;
      tabController = TabController(length: lengths, vsync: this);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (ctx) {
        scaffoldContext = ctx;
        return Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              controller: tabController,
              isScrollable: true,
              tabs: tabbar.map((tab) => Tab(text: tab['name'])).toList(),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.lightBlueAccent,
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: TextStyle(fontSize: 20),
            ),
            title: const Text(
              'DailyGrid',
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) {
                      return AlertDialog(
                        backgroundColor: const Color.fromARGB(220, 50, 50, 50),
                        title: const Text(
                          'Update Tab Name',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        content: Form(
                          key: updateFormKey,
                          child: TextFormField(
                            style: TextStyle(color: Colors.white),
                            onTapOutside: (event) {
                              FocusScope.of(context).unfocus();
                            },
                            controller: updatenameController,
                            validator: (value) => value == null || value.isEmpty
                                ? 'Required'
                                : null,
                            decoration: InputDecoration(
                              hintStyle: TextStyle(color: Colors.grey.shade500),
                              hintText: "Enter Update Tab Name",
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              fillColor: Color.fromARGB(255, 80, 80, 80),
                              filled: true,
                            ),
                          ),
                        ),
                        actionsAlignment: MainAxisAlignment.center,
                        actions: [
                          TextButton(
                            onPressed: () async {
                              if (updateFormKey.currentState!.validate()) {
                                Navigator.of(context).pop();
                                setState(() {
                                  tabbar[tabController.index]['name'] =
                                      updatenameController.text;
                                });
                                await saveTasks();
                                updatenameController.clear();
                              }
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.lightBlueAccent,
                            ),
                            child: Text(
                              'Ok',
                              style: TextStyle(color: Colors.black54),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                Navigator.of(context).pop();
                                updatenameController.clear();
                              });
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                33,
                                33,
                                33,
                              ),
                              padding: const EdgeInsets.symmetric(
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
                icon: Icon(Icons.edit, color: Colors.white, size: 30),
              ),
              IconButton(
                onPressed: () {
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        actionsAlignment: MainAxisAlignment.center,
                        backgroundColor: const Color.fromARGB(220, 50, 50, 50),
                        title: const Text(
                          'Add Tab',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        content: Form(
                          key: formKey,
                          child: TextFormField(
                            style: TextStyle(color: Colors.white),
                            onTapOutside: (event) {
                              FocusScope.of(context).unfocus();
                            },
                            controller: nameController,
                            validator: (value) => value == null || value.isEmpty
                                ? 'Required'
                                : null,
                            decoration: InputDecoration(
                              hintText: "Enter Tab Name",
                              hintStyle: TextStyle(color: Colors.grey.shade500),
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              fillColor: Color.fromARGB(255, 80, 80, 80),
                              filled: true,
                            ),
                          ),
                        ),
                        actions: [
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.lightBlueAccent,
                            ),
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                Navigator.of(context).pop();
                                setState(() {
                                  tabbar.add({
                                    'name': nameController.text,
                                    'tasks': <Task>[],
                                  });
                                  lengths++;
                                  tabController.dispose();
                                  tabController = TabController(
                                    length: lengths,
                                    vsync: this,
                                  );
                                });
                                await saveTasks();
                                nameController.clear();
                              }
                            },
                            child: const Text(
                              "OK",
                              style: TextStyle(color: Colors.black54),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              nameController.clear();
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                33,
                                33,
                                33,
                              ),
                              padding: const EdgeInsets.symmetric(
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
                icon: Icon(
                  Icons.add_circle_outline,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              if (lengths > 1)
                IconButton(
                  onPressed: () {
                    setState(() {
                      tabbar.removeAt(tabController.index);
                      lengths--;
                      tabController.dispose();
                      tabController = TabController(
                        length: lengths,
                        vsync: this,
                      );
                    });
                    saveTasks();
                  },
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
            ],
            backgroundColor: Color.fromARGB(255, 33, 33, 33),
          ),
          backgroundColor: const Color.fromARGB(255, 20, 20, 20),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.lightBlueAccent,
            onPressed: () {
              showDialog(
                barrierDismissible: false,
                barrierColor: const Color.fromARGB(200, 0, 0, 0),
                context: context,
                builder: (context) {
                  return StatefulBuilder(
                    builder: (context, setsta) {
                      return AlertDialog(
                        backgroundColor: const Color.fromARGB(200, 60, 60, 60),
                        title: const Text(
                          'Add Tasks',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        content: SizedBox(
                          height: 140,
                          width: 300,
                          child: Column(
                            children: [
                              TextField(
                                style: TextStyle(color: Colors.white),
                                onTapOutside: (_) =>
                                    FocusScope.of(context).unfocus(),
                                onChanged: (value) {
                                  setsta(() {
                                    numberenable = value.isNotEmpty;
                                  });
                                },
                                controller: numberController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade500,
                                  ),
                                  hintText: "Enter number of cards",
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  fillColor: Color.fromARGB(255, 80, 80, 80),
                                  filled: true,
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                style: TextStyle(color: Colors.white),
                                onTapOutside: (_) =>
                                    FocusScope.of(context).unfocus(),
                                controller: dateController,
                                keyboardType: TextInputType.datetime,
                                decoration: InputDecoration(
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade500,
                                  ),
                                  hintText: "Enter Date (dd/MM/yyyy)",
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  fillColor: Color.fromARGB(255, 80, 80, 80),
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
                                    final List<Task> tasks = [];
                                    setState(() {
                                      List date;
                                      if (dateController.text.isNotEmpty) {
                                        date = dateController.text.split('/');
                                      } else {
                                        date = DateFormat(
                                          'dd/MM/yyyy',
                                        ).format(DateTime.now()).split('/');
                                      }
                                      int year, month, day;
                                      try {
                                        year = int.parse(date[2]);
                                        month = int.parse(date[1]);
                                        day = int.parse(date[0]);

                                        int number =
                                            int.tryParse(
                                              numberController.text,
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
                                        return;
                                      }
                                    });
                                    tabbar[tabController.index]['tasks'] =
                                        tasks;
                                    await saveTasks();
                                    numberController.clear();
                                    dateController.clear();
                                    setState(() {
                                      numberenable = false;
                                    });
                                  }
                                : null,
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.lightBlueAccent,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),

                              disabledBackgroundColor: const Color.fromARGB(
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
                                    ? Colors.black54
                                    : const Color.fromARGB(105, 255, 255, 255),
                                fontSize: 16,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              numberController.clear();
                              dateController.clear();
                              setState(() {
                                numberenable = false;
                              });
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                33,
                                33,
                                33,
                              ),
                              padding: const EdgeInsets.symmetric(
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
            child: const Icon(Icons.add, color: Colors.black),
          ),
          body: SafeArea(
            child: TabBarView(
              controller: tabController,
              children: List.generate(tabbar.length, (j) {
                return (tabbar[j]['tasks'] as List<Task>).isNotEmpty
                    ? Stack(
                        children: [
                          GridView.builder(
                            controller: scrollController,
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
                                  crossAxisCount: 2,
                                  mainAxisExtent: 120,
                                ),
                            itemCount: tabbar[j]['tasks'].length,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () async {
                                  setState(() {
                                    tabbar[j]['tasks'][index].isDone =
                                        !tabbar[j]['tasks'][index].isDone;
                                  });
                                  await saveTasks();
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black54,
                                        offset: Offset(-4, -4),
                                        spreadRadius: -2,
                                        blurRadius: 5,
                                      ),
                                      BoxShadow(
                                        color: const Color.fromARGB(
                                          16,
                                          255,
                                          255,
                                          255,
                                        ),
                                        offset: Offset(4, 4),
                                        spreadRadius: -2,
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Card(
                                    elevation: 0,
                                    color:
                                        // tabbar[j]['tasks'][index].isDone
                                        //     ? const Color.fromARGB(255, 20, 71, 23)
                                        const Color.fromARGB(255, 20, 20, 20),
                                    child: Center(
                                      child: tabbar[j]['tasks'][index].isDone
                                          ? const Icon(
                                              Icons.task_alt_outlined,
                                              color: Colors.lightBlueAccent,
                                              size: 50,
                                            )
                                          : ListTile(
                                              title: Text(
                                                textAlign: TextAlign.center,
                                                '${tabbar[j]['tasks'][index].number}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 25,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              subtitle: Text(
                                                textAlign: TextAlign.center,
                                                DateFormat('dd/MM/yyyy').format(
                                                  tabbar[j]['tasks'][index]
                                                      .date,
                                                ),
                                                style: const TextStyle(
                                                  color: Colors.white54,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          Positioned(
                            top: 10,
                            left: 10,
                            child: IconButton(
                              onPressed: () {
                                scrollController.animateTo(
                                  scrollController.position.maxScrollExtent,
                                  duration: Duration(seconds: 3),
                                  curve: Curves.linear,
                                );
                              },
                              color: Colors.white,
                              iconSize: 30,
                              style: IconButton.styleFrom(
                                backgroundColor: Color.fromARGB(
                                  255,
                                  33,
                                  33,
                                  33,
                                ),
                              ),
                              icon: Icon(Icons.arrow_downward_outlined),
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            left: 10,
                            child: IconButton(
                              onPressed: () {
                                scrollController.animateTo(
                                  0.0,
                                  duration: Duration(seconds: 3),
                                  curve: Curves.linear,
                                );
                              },
                              color: Colors.white,
                              iconSize: 30,
                              style: IconButton.styleFrom(
                                backgroundColor: Color.fromARGB(
                                  255,
                                  33,
                                  33,
                                  33,
                                ),
                              ),
                              icon: Icon(Icons.arrow_upward_outlined),
                            ),
                          ),
                        ],
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
                      );
              }),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    tabController.dispose();
    numberController.dispose();
    dateController.dispose();
    nameController.dispose();
    super.dispose();
  }
}
