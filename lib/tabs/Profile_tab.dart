import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/UserModel.dart';
import '../screens/login_screen.dart';

class ProfilePage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const ProfilePage(
      {super.key, required this.userModel, required this.firebaseUser,});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body:
         SingleChildScrollView(
           child: Padding(
            padding: EdgeInsets.symmetric(vertical: 50, horizontal: 30),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(100.0),
                  child: CachedNetworkImage(
                    imageUrl: widget.userModel.profilepic.toString(),
                    width: 175,
                    height: 175,
                    fit: BoxFit.fill,
                    errorWidget: (context, url, error) => CircleAvatar(
                      child: Icon(CupertinoIcons.person),
                    ),
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                Text(
                  widget.userModel.email.toString(),
                  style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5),
                ),

                SizedBox(height: 35,),

                TextFormField(
                  readOnly: true,
                  initialValue: widget.userModel.fullname.toString(),
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person, color: Colors.blue,),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      label: Text('Name', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),)
                  ),
                ),

              SizedBox(height: 25,),

                TextFormField(
                  readOnly: true,
                  initialValue: widget.userModel.mobile.toString(),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.phone_rounded, color: Colors.blue,),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      label: const Text('Mobile no.', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),)
                  ),
                ),

                SizedBox(
                  height: 25,
                ),
                TextFormField(
                  readOnly: true,
                  initialValue: widget.userModel.about.toString(),
                  decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.info_outline,
                        color: Colors.blue,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                        BorderSide(color: Colors.grey, width: 1.0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                        BorderSide(color: Colors.grey, width: 1.0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      label: Text(
                        'About',
                        style: TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.w500),
                      )),
                ),
              ],
            ),
        ),
         ),
        floatingActionButton: Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: FloatingActionButton.extended(
            backgroundColor: Colors.redAccent,
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.popUntil(context, (route) => route.isFirst);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return const LoginPage();
                  }),
                );
              },
            icon: Icon(Icons.logout_outlined),
            label: Text('Logout'),)
          ),
        ),
    );
  }
}
