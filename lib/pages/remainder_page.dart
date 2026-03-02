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
  final User user = FirebaseAuth.instance.currentUser!; /// IT CHECK THE CURRENT USER LOGIN
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
              await FirebaseAuth.instance.signOut(); /// LOGOUT FROM THE CURRENT ACCOUNT
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const RegisterationPage()),
                (route) => false, ///OPEN A NEW SCREEN AND REMOVE THE OLD SCREEN
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<ReminderModel>>( /// which is USED TO STORE FIREBASE DATA WITHOUT RELOAD AUTO UPDATE THE SCREEN
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
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              final reminder = reminders[index];

              return Card( /// WHICH CONSIST OF LEADING IN LEFT
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: ListTile(
                  leading: const Icon(
                    Icons.notifications_active,
                    color: Colors.green,
                  ),
                  title: Text(reminder.taskname),/// TITLE AND SUBTITLE IN THE CENTER
                  subtitle: Text(
                    '${reminder.repeat} - '
                    '${reminder.date.day}/${reminder.date.month}/${reminder.date.year}',
                  ),
                  trailing: IconButton( /// RIGHT SIDE END
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      if (reminder.docId != null) {
                        await firestoreService.deleteReminder(reminder.docId!);
                      }
                    },
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
