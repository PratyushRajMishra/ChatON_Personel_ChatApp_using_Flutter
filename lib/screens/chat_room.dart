import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chaton/main.dart';
import 'package:chaton/models/MessageModel.dart';
import 'package:chaton/screens/targetProfile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/ChatRoomModel.dart';
import '../models/UserModel.dart';

class ChatRoomPage extends StatefulWidget {
  final UserModel targetUser;
  final ChatRoomModel chatroom;
  final UserModel userModel;
  final User firebaseUser;

  const ChatRoomPage(
      {super.key,
      required this.targetUser,
      required this.chatroom,
      required this.userModel,
      required this.firebaseUser});

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  TextEditingController messageController = TextEditingController();

  void clearChat(messageid) async {
    await FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(widget.chatroom.chatroomid)
        .collection("messages")
        .doc(messageid)
        .delete();
  }

  void sendMessage() async {
    String msg = messageController.text.trim();
    messageController.clear();

    DateTime sentTime= DateTime.now();

    if (msg != "") {
      MessageModel newMessage = MessageModel(
        messageid: uuid.v1(),
        sender: widget.userModel.uid,
        createdon: sentTime,
        text: msg,
        seen: false,
      );

      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .collection("messages")
          .doc(newMessage.messageid)
          .set(newMessage.toMap());

      widget.chatroom.lastMessage = msg;
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .set(widget.chatroom.toMap());

      widget.chatroom.lastMsgtime = sentTime;
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .set(widget.chatroom.toMap());

      print("Message Sent!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          title: Row(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(100.0),
              child: CachedNetworkImage(
                imageUrl: widget.targetUser.profilepic.toString(),
                width: 40,
                height: 40,
                fit: BoxFit.fill,
                errorWidget: (context, url, error) => CircleAvatar(
                  child: Icon(CupertinoIcons.person),
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            InkWell(
              child: Container(
                  height: 40,
                  child: Center(
                      child: Text(widget.targetUser.fullname.toString()))),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return TargetProfilePage(
                      targetUser: widget.targetUser,
                      firebaseUser: widget.firebaseUser);
                }));
              },
            ),
          ]),
        ),
        body: SafeArea(
          child: Container(
            child: Column(
              children: [
                Expanded(
                    child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("chatrooms")
                        .doc(widget.chatroom.chatroomid)
                        .collection("messages")
                        .orderBy("createdon", descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.active) {
                        if (snapshot.hasData) {
                          QuerySnapshot dataSnapshot =
                              snapshot.data as QuerySnapshot;

                          return ListView.builder(
                            reverse: true,
                            itemCount: dataSnapshot.docs.length,
                            itemBuilder: (context, index) {
                              MessageModel currentMessage =
                                  MessageModel.fromMap(dataSnapshot.docs[index]
                                      .data() as Map<String, dynamic>);
                              return Row(
                                mainAxisAlignment: (currentMessage.sender ==
                                        widget.userModel.uid)
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: EdgeInsets.symmetric(
                                      vertical: 2,
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 10),
                                    decoration: BoxDecoration(
                                      color: (currentMessage.sender ==
                                              widget.userModel.uid)
                                          ? Colors.green[400]
                                          : Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      currentMessage.text.toString(),
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text("Something went wrong!!"),
                          );
                        } else {
                          return Center(
                            child: Text("Say hi to your new friend!"),
                          );
                        }
                      } else {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  ),
                )),
                Container(
                  color: Colors.grey[300],
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: Row(
                    children: [
                      Flexible(
                        child: TextField(
                          controller: messageController,
                          maxLines: null,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Enter Message"),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          sendMessage();
                        },
                        icon: Icon(
                          Icons.send,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
