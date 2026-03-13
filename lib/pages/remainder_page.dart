import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:remainder/pages/setting_page.dart';
import 'package:remainder/pages/task_page.dart';
import '../model/remainder.dart';
import '../service/firestore_service.dart';
import 'create_task.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User user = FirebaseAuth.instance.currentUser!;
  final FirestoreService firestoreService = FirestoreService();

  int _selectedIndex = 0;
  final List<Widget> _pages = [HomePage(), TaskPage(), SettingPage()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  bool? isView = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Reminders')),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,

      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateTask()),
          );
        },
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_rounded),
            label: "Task Calendar",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Setting"),
        ],
      ),
      body: _selectedIndex == 0
          /// ADD DELETE UPDATE THE REMINDER  TASK AND UPDATE THE UI AUTOMATICALLY
          ? StreamBuilder<List<ReminderModel>>(
              /// DISPLAY THE TASK OF THE LOGIN USER USING UID
              stream: firestoreService.getReminders(user.uid),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      snapshot.error.toString(),
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset(
                          "assets/animation.json",
                          width: 150,
                          height: 100,
                          repeat: true,
                          animate: false,
                        ),
                        const Text(
                          'No reminders found!',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final reminders = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),

                  ///LENGTH OF THE USER CREATED LIST
                  itemCount: reminders.length,

                  /// IT CREATE EACH AND EVERY INDEX
                  itemBuilder: (context, index) {
                    /// IT DISPLAY THE VALUE ACCORDING TO THE INDEX VALUE
                    final reminder = reminders[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),

                      /// CHOOSE COLOR FOR THE COMPLETE ICON STATUS
                      child: ListTile(
                        leading: Icon(
                          reminder.isCompleted == null
                              ? Icons.notifications_active
                              : reminder.isCompleted!
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: reminder.isCompleted == null
                              ? Colors.orange
                              : reminder.isCompleted!
                              ? Colors.green
                              : Colors.red,
                        ),
                        onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CreateTask(
                                  existingReminder: reminder,
                                  isView: true,
                                ),
                          ),
                        );
                      },

                        /// THE LIST ITEM DISPLAY IN THIS ORDER
                        title: Text(
                          reminder.taskname,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),

                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${reminder.repeat} - ${reminder.date.day}/${reminder.date.month}/${reminder.date.year}',
                            ),


                            /// COLORS CHOOSE FOR THE COMPLETE INCOMPLETE PENDING
                            Text(
                              reminder.isCompleted == null
                                  ? "Pending"
                                  : reminder.isCompleted!
                                  ? "Completed"
                                  : "Cancel",
                              style: TextStyle(
                                color: reminder.isCompleted == null
                                    ? Colors.orange
                                    : reminder.isCompleted!
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            /// POPUP MENU BUTTON WITH THREE DORT
                            PopupMenuButton<String>(
                              onSelected: (value) async {
                                /// IF THE USER CLICK VIEW
                                if (value == "view") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CreateTask(
                                        existingReminder: reminder,
                                        isView: true,
                                      ),
                                    ),
                                  );
                                }


                                ///IF THE USER CLICK EDIT
                                if (value == "edit") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CreateTask(
                                        existingReminder: reminder,
                                      ),
                                    ),
                                  );
                                }

                                /// IF THE USER CLICK COMPLETE
                                if (value == "complete") {
                                  final TextEditingController
                                  descriptionController =
                                      TextEditingController();

                                  final confirm = await showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text("Complete Reminder"),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text(
                                              "What did you complete?",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            TextField(
                                              controller: descriptionController,
                                              decoration: const InputDecoration(
                                                hintText:
                                                    "Enter description...",
                                                border: OutlineInputBorder(),
                                              ),
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context, false);
                                            },
                                            child: const Text("Cancel"),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context, true);
                                            },
                                            child: const Text(
                                              "Complete",
                                              style: TextStyle(
                                                color: Colors.green,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (confirm == true &&
                                      reminder.docId != null) {
                                    await firestoreService.updateStatus(
                                      reminder.docId!,
                                      true,
                                    );

                                    if (context.mounted) {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) {
                                          return AlertDialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: const [
                                                Icon(
                                                  Icons.check_circle,
                                                  color: Colors.green,
                                                  size: 80,
                                                ),
                                                SizedBox(height: 15),
                                                Text(
                                                  "Successfully Done",
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(height: 10),
                                                Text(
                                                  "Your reminder task has been completed",
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text("OK"),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  }
                                }

                                ///IF THE CLICK CHOOSE INCOMPLETE
                                if (value == "cancel") {
                                  final bool? confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text('Cancel Reminder'),
                                        content: const Text(
                                          "Are you sure you want to cancel the reminder?",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context, false);
                                            },
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context, true);
                                            },
                                            child: const Text(
                                              'OK',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (confirm == true) {
                                    if (reminder.docId != null) {
                                      await firestoreService.updateStatus(
                                        reminder.docId!,
                                        false, // FIXED HERE
                                      );
                                    }
                                  }
                                }

                                ///IF THE USER CLICK DELETE OPTIONS
                                if (value == "delete") {
                                  final confirm = await showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text("Delete Reminder"),
                                        content: const Text(
                                          "Are you sure you want to delete this reminder?",
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context, false);
                                            },
                                            child: const Text("Cancel"),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context, true);
                                            },
                                            child: const Text(
                                              "Delete",
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (confirm == true &&
                                      reminder.docId != null) {
                                    await firestoreService.deleteReminder(
                                      reminder.docId!,
                                    );
                                  }
                                }
                              },

                              ///THE TOTAL OPTIONS THAT ARE DISPLAYED IN THE POPUP MENU ICON
                              itemBuilder: (context) => [
                                if (reminder.isCompleted == null) ...[
                                  const PopupMenuItem(
                                    value: "view",
                                    child: Text("View"),
                                  ),
                                  const PopupMenuItem(
                                    value: "complete",
                                    child: Text("Complete"),
                                  ),
                                  const PopupMenuItem(
                                    value: "cancel",
                                    child: Text("cancel"),
                                  ),
                                  const PopupMenuItem(
                                    value: "edit",
                                    child: Text("Edit"),
                                  ),
                                  const PopupMenuItem(
                                    value: "delete",
                                    child: Text("Delete"),
                                  ),
                                ] else if (reminder.isCompleted == true) ...[
                                  const PopupMenuItem(
                                    value: 'view',
                                    child: Text('view'),
                                  ),
                                  const PopupMenuItem(
                                    value: "delete",
                                    child: Text("Delete"),
                                  ),
                                ] else ...[
                                  const PopupMenuItem(
                                    value: "view",
                                    child: Text("View"),
                                  ),
                                  const PopupMenuItem(
                                    value: "edit",
                                    child: Text("Edit"),
                                  ),
                                  const PopupMenuItem(
                                    value: "delete",
                                    child: Text("Delete"),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            )
          : _pages[_selectedIndex],
    );
  }
}
