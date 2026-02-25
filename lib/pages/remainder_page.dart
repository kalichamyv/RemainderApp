import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:remainder/pages/create_task.dart';
import 'package:remainder/model/remainder.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User user = FirebaseAuth.instance.currentUser!;
  List<ReminderModel> reminders = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reminders'),
        actions: [                        /// it is used to create a buttons or icons on right side of the screen
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const RegisterationPage(),/// user gives the logout icon
                ),
                    (route) => false,
              );
            },
          ),
        ],
      ),
      body: reminders.isEmpty
          ? const Center(
        child: Text(
          'no remainders yet found !!!',
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView.builder(
        itemCount: reminders.length,
        itemBuilder: (context, index) {
          final reminder = reminders[index];

          return Card(
            margin: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            child: ListTile(
              leading: const Icon(
                Icons.notifications_active,
                color: Colors.green,
              ),
              title: Text(reminder.taskname),
              subtitle: Text(
                '${reminder.repeat}'
                    '${reminder.date.day}/${reminder.date.month}/${reminder.date.year}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: Icon(Icons.delete,color: Colors.red,),onPressed: () {
                    setState(() {
                      reminders.removeAt(index);
                    });
                  },),
                  IconButton(icon: Icon(Icons.arrow_forward_ios),
                    onPressed: () {
                      print('view');
                    },
                  ),
                ],
              )
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        shape: CircleBorder(),
        onPressed: () async {
          final reminder = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateTask(),
            ),
          );

          if (reminder != null) {
            setState(() {
              reminders.add(reminder);
            });
          }
        },
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}