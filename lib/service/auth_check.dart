import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:remainder/pages/login_page.dart';

import '../pages/remainder_page.dart';

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    /// AUTOMATICALLY REBUILD THE UI WHEN THE NEW VALUE IS ADDED
    return StreamBuilder<User?>(
      /// IT SHOWS THE DATA OF THE PARTICULAR USER WHICH THE USER IS LOGIN CURRENTLY USER?
      stream: FirebaseAuth.instance.authStateChanges(),

      /// tell me when ever login or log out
      builder: (context, snapshot) {
        /// STREAM HAS NOT EMIT NEW VALUE YET
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          /// if an existing user redirecting to homepage AND THE STREAM IS LOGIN
          /// IF THE SNAPSHOT RETURN THE "USER"
          return const HomePage();
        }

        return const RegisterationPage();

        /// else moved to registration page
      },
    );
  }
}
