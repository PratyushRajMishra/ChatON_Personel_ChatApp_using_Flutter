import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chaton/models/ChatRoomModel.dart';
import 'package:chaton/screens/about_screen.dart';
import 'package:chaton/screens/login_screen.dart';
import 'package:chaton/screens/notifications_screen.dart';
import 'package:chaton/screens/setting_screen.dart';
import 'package:chaton/screens/share_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/UserModel.dart';
import '../tabs/Profile_tab.dart';
import '../tabs/chatlist_tab.dart'

;

class HomePage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const HomePage(
      {super.key, required this.userModel, required this.firebaseUser,});

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
            PopupMenuButton(
                offset: Offset(0, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0)),
                icon: const Icon(
                  Icons.more_vert,
                  color: Colors.black,
                ),
                itemBuilder: (context) {
                  return [
                    const PopupMenuItem<int>(
                      value: 0,
                      child: Row(
                        children: [
                          Icon(
                            Icons.settings,
                            color: Colors.grey,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text("Settings"),
                        ],
                      ),
                    ),
                    const PopupMenuItem<int>(
                      value: 1,
                      child: Row(
                        children: [
                          Icon(
                            Icons.notifications,
                            color: Colors.grey,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text("Notifications"),
                        ],
                      ),
                    ),
                    const PopupMenuItem<int>(
                      value: 2,
                      child: Row(
                        children: [
                          Icon(
                            Icons.share,
                            color: Colors.grey,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text("Share"),
                        ],
                      ),
                    ),
                    const PopupMenuItem<int>(
                      value: 3,
                      child: Row(
                        children: [
                          Icon(
                            Icons.account_box_outlined,
                            color: Colors.grey,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text("About"),
                        ],
                      ),
                    ),
                    const PopupMenuItem<int>(
                      value: 4,
                      child: Row(
                        children: [
                          Icon(
                            Icons.logout,
                            color: Colors.grey,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text("Sign Out"),
                        ],
                      ),
                    ),
                  ];
                },
                onSelected: (value){
                  if (value == 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return SettingPage(userModel: widget.userModel, firebaseUser: widget.firebaseUser,);
                      }),
                    );
                  }
                  
                  else if (value == 1) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return const NotificationsPage();
                      }),
                    );
                  }

                  else if (value == 2) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return const SharePage();
                      }),
                    );
                  }

                  else if (value == 3) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return const AboutPage();
                      }),
                    );
                  }
                  else if (value == 4) {
                    FirebaseAuth.instance.signOut();
                    Navigator.popUntil(context, (route) => route.isFirst);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return const LoginPage();
                      }),
                    );
                  }
                }),

          ],
          bottom: TabBar(
            indicatorWeight: 3,
            tabs: [
              const Tab(
                icon: Icon(
                  Icons.chat_rounded,
                  color: Colors.blue,
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(100.0),
                child: CachedNetworkImage(
                  imageUrl: widget.userModel.profilepic.toString(),
                  width: 30,
                  height: 30,
                  fit: BoxFit.fill,
                  errorWidget: (context, url, error) => CircleAvatar(
                    child: Icon(CupertinoIcons.person),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ChatPage(
                userModel: widget.userModel, firebaseUser: widget.firebaseUser,),
            ProfilePage(
              userModel: widget.userModel,
              firebaseUser: widget.firebaseUser,
            ),
          ],
        ),

      )
  );


}


