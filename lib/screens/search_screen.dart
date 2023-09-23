import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chaton/screens/chat_room.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../models/ChatRoomModel.dart';
import '../models/UIHelper.dart';
import '../models/UserModel.dart';

class SearchPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const SearchPage({
    super.key,
    required this.userModel,
    required this.firebaseUser,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  var searchName = "";
  TextEditingController searchController = TextEditingController();

  Future<ChatRoomModel?> getChatroomModel(UserModel targetUser) async {

    UIHelper.showLoadingDialog(context, "Connecting....");

    ChatRoomModel? chatRoom;

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .where("participants.${widget.userModel.uid}", isEqualTo: true)
        .where("participants.${targetUser.uid}", isEqualTo: true)
        .get();

    if (snapshot.docs.length > 0) {
      var docData = snapshot.docs[0].data();
      ChatRoomModel existingChatroom =
      ChatRoomModel.fromMap(docData as Map<String, dynamic>);

      chatRoom = existingChatroom;

      print("chatroom already created!");
    } else {
      ChatRoomModel newChatroom = ChatRoomModel(
          chatroomid: uuid.v1(),
          lastMessage: "",
          participants: {
            widget.userModel.uid.toString(): true,
            targetUser.uid.toString(): true,
          },
          users: [widget.userModel.uid.toString(), targetUser.uid.toString()],
          createdon: DateTime.now());
      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(newChatroom.chatroomid)
          .set(newChatroom.toMap());


      chatRoom = newChatroom;
      print("new chatRoom created!");
    }
    return chatRoom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(titleSpacing: 12,
          backgroundColor: Colors.green.shade400,
          title: SizedBox(
            height: 45,
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchName = value;
                });
              },
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none),
                  contentPadding:
                  EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  filled: true,
                  fillColor: Colors.blue.shade50,
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.w300),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.black,
                  )),
            ),
          )),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users').where("fullname", isNotEqualTo: widget.userModel.fullname)
              .orderBy('fullname')
              .startAt([searchName]).endAt(["$searchName\uf8ff"]).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {

                return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                      UserModel searchedUser = UserModel.fromMap(data);

                      return ListTile(
                        onTap: () async {
                          ChatRoomModel? chatroomModel =
                          await getChatroomModel(searchedUser);

                          if (chatroomModel != null) {
                            Navigator.pop(context);
                            Navigator.pop(context);
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                                  return ChatRoomPage(
                                    targetUser: searchedUser,
                                    userModel: widget.userModel,
                                    firebaseUser: widget.firebaseUser,
                                    chatroom: chatroomModel,
                                  );
                                }));
                          }
                        },
                        leading:  ClipRRect(
                          borderRadius: BorderRadius.circular(100.0),
                          child: CachedNetworkImage(
                            imageUrl: data['profilepic'!].toString(),
                            width: 50,
                            height: 50,
                            fit: BoxFit.fill,
                            errorWidget: (context, url, error) => CircleAvatar(
                              child: Icon(CupertinoIcons.person),
                            ),
                          ),
                        ),
                        title: Text(data['fullname'!]),
                        subtitle: Text(data['email'!]),
                        trailing: const Icon(Icons.keyboard_arrow_right),
                      );
                    });
              } else {
                return const Text("No results found");
              }
            } else if (snapshot.hasError) {
              return const Text("Something went wrong!");
            } else {
              return Center(child: CircularProgressIndicator());
            }

          }),
    );
  }
}