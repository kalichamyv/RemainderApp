import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../service/service_check.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final User user = FirebaseAuth.instance.currentUser!;
    final AuthService _authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.logout();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome ",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text("Email: ${user.email}"),
            Text("User ID: ${user.uid}"),
            Text("Created: ${user.metadata.creationTime}"),
            Text("phone no: ${user.phoneNumber}"),
          ],
        ),
      ),
    );
  }
}