import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/remainder.dart';
import '../service/firestore_service.dart';
import 'create_task.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User user = FirebaseAuth.instance.currentUser!;
  final FirestoreService firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reminders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const RegisterationPage()),
                    (route) => false,
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<ReminderModel>>(
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
            return const Center(
              child: Text(
                'No reminders found!',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final reminders = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              final reminder = reminders[index];

              return Card(
                margin:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                  title: Text(
                    reminder.taskname,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Date
                      Text(
                        '${reminder.repeat} - '
                            '${reminder.date.day}/${reminder.date.month}/${reminder.date.year}',
                      ),

                      /// Status Text
                      Text(
                        reminder.isCompleted == null
                            ? "Pending"
                            : reminder.isCompleted!
                            ? "Completed"
                            : "Incomplete",
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

                      /// COMPLETE / INCOMPLETE BUTTONS ONLY IF PENDING
                      if (reminder.isCompleted == null) ...[
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () async {
                            if (reminder.docId != null) {
                              await firestoreService.updateStatus(
                                  reminder.docId!, true);
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () async {
                            if (reminder.docId != null) {
                              await firestoreService.updateStatus(
                                  reminder.docId!, false);
                            }
                          },
                        ),
                      ],

                      /// EDIT
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  CreateTask(existingReminder: reminder),
                            ),
                          );
                        },
                      ),

                      /// DELETE
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          if (reminder.docId != null) {
                            await firestoreService
                                .deleteReminder(reminder.docId!);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
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
    );
  }
}