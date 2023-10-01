import 'package:chaton/models/UserModel.dart';
import 'package:chaton/screens/signup_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/UIHelper.dart';
import 'home_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void checkvalues() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email == "" || password == "") {
      UIHelper.shoeAlertDialog(context, "Incomplete Data", "Please fill all the fields!");
    } else {
      logIn(email, password);
    }
  }

  void logIn(String email, String password) async {
    UserCredential? credential;

    UIHelper.showLoadingDialog(context, "Logging In..");

    try {
      credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      Navigator.pop(context);
      UIHelper.shoeAlertDialog(context, "An error occured", ex.message.toString());
    }

    if (credential != null) {
      String uid = credential.user!.uid;

      DocumentSnapshot userData =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      UserModel userModel =
          UserModel.fromMap(userData.data() as Map<String, dynamic>);

      print("Log in Successfully!");
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context){
          return HomePage(userModel: userModel, firebaseUser: credential!.user!);
        }
        ),
      );
    }
  }

  void _showForgotPasswordDialog() {
    TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Forgot Password?"),
          content: TextField(
            controller: emailController,
            decoration: InputDecoration(
              hintText: "Enter your email",
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Reset Password"),
              onPressed: () async {
                String email = emailController.text.trim();

                if (email.isNotEmpty) {
                  try {
                    await FirebaseAuth.instance.sendPasswordResetEmail(
                      email: email,
                    );
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Please check your email to reset your password.",
                        ),
                        duration: Duration(seconds: 5), // Adjust the duration as needed
                      ),
                    );
                  } on FirebaseAuthException catch (ex) {
                    UIHelper.shoeAlertDialog(
                      context,
                      "An error occurred",
                      ex.message.toString(),
                    );
                  }
                } else {
                  UIHelper.shoeAlertDialog(
                    context,
                    "Incomplete Data",
                    "Please enter your email.",
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 25),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Image.asset('assets/splash.png'),
                  SizedBox(
                    height: 80,
                  ),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.email_outlined, color: Colors.black,),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1.0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1.0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        label: Text('Email', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),)
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  TextFormField(
                    obscureText: true,
                    controller: passwordController,
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.password_outlined, color: Colors.black,),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1.0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1.0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        label: Text('Password', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),)
                    ),
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Colors.amber.shade900, // Customize the color as needed
                        ),
                      ),
                      onPressed: () {
                        _showForgotPasswordDialog();
                      },
                    ),
                  ),

                  SizedBox(
                    height: 50,
                  ),
                  CupertinoButton(
                      child: Text(
                        'LOGIN',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      color: Theme.of(context).colorScheme.secondary,
                      onPressed: () {
                        checkvalues();
                      }),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Dont't have an account?",
              style: TextStyle(fontSize: 16),
            ),
            TextButton(
                child: Text('Sign up',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.green,
                        fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return SignupPage();
                    }),
                  );
                }),
          ],
        ),
      ),
    );
  }
}
