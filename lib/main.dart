import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:remainder/service/notification_service.dart';

import 'auth/auth_check.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); /// start the flutter
  await Firebase.initializeApp();/// connecting fire base
  await FirebaseFirestore.instance
      /// create a collection
      .collection('firestore_connection_test')
      /// in firestore collection
      .doc('test')
      .set({'ok': true});

  /// store the document as test click ok as save
  await NotificationService.init();
  // print('Init is called');
  await NotificationService.requestPermission();
  /// mobile notification permissions
  // print('fire base is called');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Remainder',
      home: AuthCheck(),
    );
  }
}
