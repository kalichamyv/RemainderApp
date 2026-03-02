import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:remainder/pages/registeration_page.dart';
import 'package:remainder/pages/remainder_page.dart';
import 'package:remainder/service/service_check.dart';

class RegisterationPage extends StatefulWidget {
  const RegisterationPage({super.key});

  @override
  State<RegisterationPage> createState() => _RegisterationPageState();
}

class _RegisterationPageState extends State<RegisterationPage> {
  final EmailController = TextEditingController();
  final PassWordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  bool isLoading = false;

  @override
  void dispose() {
    EmailController.dispose(); /// once the user enter the next page the text field will cleared automatically
    PassWordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(padding: EdgeInsets.only(left: 40, right: 20)),
                Column(
                  children: [
                    Text("LOG in", style: TextStyle(fontSize: 35)),
                    Text(
                      'enter your gmail and password to securely access your account',
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: EmailController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "E-Mail",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email should not be empty';
                        }
                        if (!value.contains('@gmail.com')) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: PassWordController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.security_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        hintText: "Password ",
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'password should not be empty';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) { /// there should not be empty field there
                          try { /// wrong password, mail,internet,
                            await _authService.login( /// check whether old  user
                              email: EmailController.text.trim(),///REMOVE SPACES
                              password: PassWordController.text.trim(),
                            );

                            Navigator.pushReplacement(///ENTER TO NEW PAGE FORM AN EXISTING PAGE
                              context,
                              MaterialPageRoute(
                                builder: (_) => const HomePage(),
                              ),
                            );
                          } on FirebaseAuthException catch (e) { /// IF FIREBASE THROWS AN ERROR CATCH THE ERROR AND
                            String message;  /// CONVERT IT TO STRING

                            if (e.code == 'invalid-email') {
                              message = 'Invalid email address';
                            } else if (e.code == 'password') {
                              message = 'Invalid password';
                            } else {
                              message = 'Email or password is incorrect';
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(message),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        }
                      },
                      child: Text('LOGIN'),
                    ),
                    Text.rich(
                      TextSpan(
                        text: "Don't you have Account ?",
                        style: TextStyle(color: Colors.black),
                        children: [
                          TextSpan(
                            text: "Sign up here ?",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginPage(),
                                  ),
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
