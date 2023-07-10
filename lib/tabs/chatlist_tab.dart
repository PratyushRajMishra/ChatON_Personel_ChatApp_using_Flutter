import 'package:flutter/material.dart';
import 'dart:developer';

import 'package:chaton/models/ChatRoomModel.dart';
import 'package:chaton/models/FirebaseHelper.dart';
import 'package:chaton/models/UIHelper.dart';
import 'package:chaton/screens/chat_room.dart';
import 'package:chaton/screens/login_screen.dart';
import 'package:chaton/screens/search_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/UserModel.dart';

class ChatPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const ChatPage({super.key, required this.userModel, required this.firebaseUser});


  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("chatrooms").where("users", arrayContains: widget.userModel.uid).
            orderBy("createdon").snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData) {
                  QuerySnapshot chatRoomSnapshot =
                  snapshot.data as QuerySnapshot;

                  return ListView.separated(
                    itemCount: chatRoomSnapshot.docs.length,
                    itemBuilder: (context, index) {
                      ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                          chatRoomSnapshot.docs[index].data()
                          as Map<String, dynamic>);

                      Map<String, dynamic> participants =
                      chatRoomModel.praticipants!;

                      List<String> participantKeys = participants.keys.toList();
                      participantKeys.remove(widget.userModel.uid);

                      return FutureBuilder(
                        future:
                        FirebaseHelper.getUserModelById(participantKeys[0]),
                        builder: (context, userData) {
                          if (userData.connectionState ==
                              ConnectionState.done) {
                            if (userData != null) {
                              UserModel targetUser = userData.data as UserModel;

                              return ListTile(
                                  onTap: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                          return ChatRoomPage(
                                              targetUser: targetUser,
                                              chatroom: chatRoomModel,
                                              userModel: widget.userModel,
                                              firebaseUser: widget.firebaseUser);
                                        }));
                                  },
                                  leading: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        targetUser.profilepic.toString()),
                                  ),
                                  title: Text(targetUser.fullname.toString()),
                                  subtitle: (chatRoomModel.lastMessage
                                      .toString() !=
                                      '')
                                      ? Text(
                                      chatRoomModel.lastMessage.toString())
                                      : Text('Say Hi to your friend!', style: TextStyle(color: Colors.green[400]),));
                            } else {
                              return Container();
                            }
                          } else {
                            return Container();
                          }
                        },
                      );
                    }, separatorBuilder: (BuildContext context, int index) {
                    return Divider(height: 0, thickness: 1,);
                  },
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                } else {
                  return Center(
                    child: Text("No chats"),
                  );
                }
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return SearchPage(userModel: widget.userModel, firebaseUser: widget.firebaseUser);
          }));
        },
        child: Icon(Icons.search),
        backgroundColor: Colors.green[400],
      ),
    );
  }
}
