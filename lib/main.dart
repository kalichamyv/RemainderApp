import 'package:flutter/material.dart';
import 'package:remainder/screens/login_page.dart';


void main(){
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Remainder',
      home: LoginPage(),
    );
  }
}
