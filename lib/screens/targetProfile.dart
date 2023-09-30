import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/UserModel.dart';

class TargetProfilePage extends StatefulWidget {
  final UserModel targetUser;
  final User firebaseUser;

  const TargetProfilePage({
    Key? key,
    required this.targetUser,
    required this.firebaseUser,
  }) : super(key: key);

  @override
  State<TargetProfilePage> createState() => _TargetProfilePageState();
}

class _TargetProfilePageState extends State<TargetProfilePage> {

  void blockDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          title: Text("Block ${widget.targetUser.fullname}  ?"),
          content: const Text(
            'User is temporarily blocked from this side. No one can send messages or any media. ',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              child: const Text(
                'Cancel',
                style: TextStyle(fontSize: 17, color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  Navigator.pop(context);

                });
              },
              child: const Text(
                'Report and block',
                style: TextStyle(fontSize: 17, color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }




  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            color: Colors.blueGrey, icon: Icon(Icons.close_rounded, size: 30,),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100.0),
                    child: CachedNetworkImage(
                      imageUrl: widget.targetUser.profilepic.toString(),
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
                    widget.targetUser.email.toString(),
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  const Divider(thickness: 1.0),
                  SizedBox(
                    height: 35,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: TextFormField(
                      readOnly: true,
                      initialValue: widget.targetUser.fullname.toString(),
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.person,
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
                          'Name',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: TextFormField(
                      readOnly: true,
                      initialValue: widget.targetUser.mobile.toString(),
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.phone_rounded,
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
                          'Mobile no.',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: TextFormField(
                      readOnly: true,
                      initialValue: widget.targetUser.about.toString(),
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
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 35,
                  ),
                  const Divider(thickness: 1.0),
                  SizedBox(
                    height: 10,
                  ),
                  TextButton.icon(
                    onPressed: () {
                      blockDialog();
                    },
                    icon: const Icon(
                      Icons.block_sharp,
                      color: Colors.red,
                    ),
                    label: Text(
                      "Block ${widget.targetUser.fullname}",
                      style: const TextStyle(color: Colors.red, fontSize: 17),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {

                    },
                    icon: const Icon(Icons.group_add, color: Colors.green,),
                    label:
                        Text("Create Group with ${widget.targetUser.fullname}", style: TextStyle(color: Colors.green, fontSize: 17),),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
