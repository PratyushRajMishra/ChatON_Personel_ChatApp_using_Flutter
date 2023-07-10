import 'dart:developer';


import 'package:chaton/screens/login_screen.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/UserModel.dart';
import '../tabs/Profile_tab.dart';
import '../tabs/chatlist_tab.dart';

class HomePage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const HomePage(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) => DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          title: Image.asset(
            "assets/splash.png",
            width: 40,
          ),
          actions: [
            IconButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.popUntil(context, (route) => route.isFirst);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return LoginPage();
                    }),
                  );
                },
                icon: Icon(
                  Icons.exit_to_app,
                  color: Colors.blueAccent,
                ))
          ],
          bottom: TabBar(
            indicatorWeight: 3,
            tabs: [
              const Tab(
                icon: Icon(
                  Icons.mark_unread_chat_alt_sharp,
                  color: Colors.blueAccent,
                ),
              ),
              Tab(
                icon: Icon(Icons.person_pin,  color: Colors.green[400]),
              )
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ChatPage(
                userModel: widget.userModel, firebaseUser: widget.firebaseUser),
            ProfilePage(),
          ],
        ),
      ));
}
