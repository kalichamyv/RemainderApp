import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:table_calendar/table_calendar.dart';
import '../model/remainder.dart';
import '../service/firestore_service.dart';
import 'create_task.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final User user = FirebaseAuth.instance.currentUser!;
  final FirestoreService firestoreService = FirestoreService();

  CalendarFormat _calendarFormat = CalendarFormat.month;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime(2020),

          lastDay: DateTime(2030),

          focusedDay: _focusedDay,

          calendarFormat: _calendarFormat,

          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay ?? DateTime.now(), day);
          },

          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },

          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },

        availableCalendarFormats: const {
            CalendarFormat.week:"week",
            CalendarFormat.month:"month"
        },

          calendarStyle: const CalendarStyle(
            selectedDecoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
        ),
        IconButton(
          icon: Icon(
            _calendarFormat == CalendarFormat.month
                ? Icons.keyboard_arrow_down_outlined
                : Icons.keyboard_arrow_up_outlined,
          ),
          onPressed: () {
            setState(() {
              _calendarFormat = _calendarFormat == CalendarFormat.month
                  ? CalendarFormat.week
                  : CalendarFormat.month;
            });
          },
        ),

        const SizedBox(height: 10),

        /// TASK LIST
        Expanded(
          child: StreamBuilder<List<ReminderModel>>(
            stream: firestoreService.getReminders(user.uid),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text(snapshot.error.toString()));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData) {
                return const Center(child: Text("No Tasks"));
              }

              final reminders = snapshot.data!;

              /// FILTER TASK BY DATE
              final filteredTasks = reminders.where((task) {
                if (_selectedDay == null) return false;

                return task.date.year == _selectedDay!.year &&
                    task.date.month == _selectedDay!.month &&
                    task.date.day == _selectedDay!.day;
              }).toList();

              if (filteredTasks.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        "assets/empty.json",
                        repeat: true,
                        width: 140,
                        animate: false,
                      ),
                      Text(
                        "No Tasks On This Day",
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: filteredTasks.length,
                itemBuilder: (context, index) {
                  final reminder = filteredTasks[index];

                  return Card(
                    margin: const EdgeInsets.all(10),

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

                      title: Text(reminder.taskname),

                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${reminder.date.day}/${reminder.date.month}/${reminder.date.year}",
                          ),

                          Text(
                            reminder.isCompleted == null
                                ? "Pending"
                                : reminder.isCompleted!
                                ? "Completed"
                                : "cancel",
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

                      trailing: PopupMenuButton<String>(
                        onSelected: (value) async {
                          /// EDIT
                          if (value == "edit") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    CreateTask(existingReminder: reminder),
                              ),
                            );
                          }

                          /// COMPLETE
                          if (value == "complete") {
                            if (reminder.docId != null) {
                              await firestoreService.updateStatus(
                                reminder.docId!,
                                true,
                              );
                            }
                          }

                          /// INCOMPLETE
                          if (value == "incomplete") {
                            if (reminder.docId != null) {
                              await firestoreService.updateStatus(
                                reminder.docId!,
                                false,
                              );
                            }
                          }

                          /// DELETE
                          if (value == "delete") {
                            if (reminder.docId != null) {
                              await firestoreService.deleteReminder(
                                reminder.docId!,
                              );
                            }
                          }
                        },

                        itemBuilder: (context) => [
                          /// PENDING TASK
                          if (reminder.isCompleted == null) ...[
                            const PopupMenuItem(
                              value: "complete",
                              child: Text("Complete"),
                            ),

                            const PopupMenuItem(
                              value: "incomplete",
                              child: Text("Incomplete"),
                            ),

                            const PopupMenuItem(
                              value: "edit",
                              child: Text("Edit"),
                            ),

                            const PopupMenuItem(
                              value: "delete",
                              child: Text("Delete"),
                            ),
                          ]
                          /// COMPLETED TASK
                          else if (reminder.isCompleted == true) ...[
                            const PopupMenuItem(
                              value: "delete",
                              child: Text("Delete"),
                            ),
                          ]
                          /// INCOMPLETE TASK
                          else ...[
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
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
