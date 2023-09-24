import 'package:cached_network_image/cached_network_image.dart';
import 'package:chaton/models/MessageModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chaton/models/ChatRoomModel.dart';
import 'package:chaton/models/FirebaseHelper.dart';
import 'package:chaton/screens/chat_room.dart';
import 'package:chaton/screens/search_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';

import '../models/UIHelper.dart';
import '../models/UserModel.dart';
import '../screens/targetProfile.dart';

class ChatPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  ChatPage({required this.userModel, required this.firebaseUser});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController searchController = TextEditingController();
  String searched = '';

  final picker = ImagePicker();

  Future getImage() async {
    final pickerImage = await picker.pickImage(source: ImageSource.camera);
    if (pickerImage != null) {
      // Handle the selected image
    } else {
      print("No image selected");
    }
  }


  void deleteUser(ChatRoomModel chatRoomModel) async {
    final chatRoomRef = FirebaseFirestore.instance.collection('chatrooms').doc(
        chatRoomModel.chatroomid);

    try {
      // Get a reference to the messages collection for the chatroom
      final messagesRef = chatRoomRef.collection('messages');

      // Delete the chatroom
      await chatRoomRef.delete();

      // Delete all messages in the chatroom
      QuerySnapshot messagesSnapshot = await messagesRef.get();

      for (QueryDocumentSnapshot messageDoc in messagesSnapshot.docs) {
        await messageDoc.reference.delete();
      }

      // Show success snackbar
      showSnackBar(context, 'Chat deleted successfully');
    } catch (error) {
      print('Error deleting chat: $error');
      // Show error dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text(
                'Failed to delete chat. Please try again later.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }


    void showSnackBar(BuildContext context, String message) {
      final snackBar = SnackBar(
        backgroundColor: Colors.black,
        behavior: SnackBarBehavior.floating,
        content: const Text("Chat deleted successfully."), // Use the message parameter here
        action: SnackBarAction(
          label: 'Ok',
          onPressed: () {},
          textColor: Colors.white,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }


  void deleteDialog(ChatRoomModel chatRoomModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          title: const Text('Delete this chat?'),
          content: const Text(
            'User is permanently deleted from both sides, messages, and media are also deleted permanently.',
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
                  deleteUser(chatRoomModel);
                });
              },
              child: const Text(
                'Delete chat',
                style: TextStyle(fontSize: 17, color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildShimmerLoadingTile() {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ListTile(
          leading: CircleAvatar(
            radius: 20.0,
            backgroundColor: Colors.grey[300]!,
          ),
          title: Container(
            width: 150.0,
            height: 20.0,
            color: Colors.grey[300]!,
          ),
          subtitle: Container(
            width: 100.0,
            height: 15.0,
            color: Colors.grey[300]!,
          ),
          trailing: Icon(
            Icons.access_time,
            size: 15.0,
            color: Colors.grey[300]!,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("chatrooms")
                .where("users", arrayContains: widget.userModel.uid)
                .orderBy("createdon")
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData) {
                  QuerySnapshot chatRoomSnapshot = snapshot.data as QuerySnapshot;

                  if (chatRoomSnapshot.docs.isEmpty) {
                    // Display a message when there are no chat rooms
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'No chat available.',
                            style: TextStyle(color: Colors.black45, fontSize: 16),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Click on',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black45,
                                ),
                              ),
                              Text(
                                ' + ',
                                style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.black45,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'for new chat',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black45,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: chatRoomSnapshot.docs.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        ChatRoomModel chatRoomModel =
                        ChatRoomModel.fromMap(chatRoomSnapshot.docs[index]
                            .data() as Map<String, dynamic>);

                        Map<String, dynamic> participants =
                            chatRoomModel.participants ?? {};

                        List<String> participantKeys =
                        participants.keys.toList();
                        participantKeys.remove(widget.userModel.uid);

                        return FutureBuilder<UserModel?>(
                          future:
                          FirebaseHelper.getUserModelById(participantKeys[0]),
                          builder: (context, userData) {
                            if (userData.connectionState ==
                                ConnectionState.done) {
                              UserModel? targetUser = userData.data;

                              if (targetUser != null) {
                                return Card(
                                  elevation: 0.5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: InkWell(
                                    child: ListTile(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) {
                                              return ChatRoomPage(
                                                targetUser: targetUser,
                                                chatroom: chatRoomModel,
                                                userModel: widget.userModel,
                                                firebaseUser: widget.firebaseUser,
                                              );
                                            },
                                          ),
                                        );
                                      },
                                      onLongPress: () {
                                        showModalBottomSheet(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return Wrap(
                                              children: [
                                                ListTile(
                                                  title: Center(
                                                    child: Text(
                                                      targetUser.fullname
                                                          .toString(),
                                                      style: const TextStyle(
                                                        fontWeight:
                                                        FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const Divider(
                                                  color: Colors.black54,
                                                ),
                                                ListTile(
                                                  title: TextButton.icon(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      deleteDialog(
                                                          chatRoomModel);
                                                    },
                                                    icon: const Icon(
                                                      Icons.delete,
                                                      color: Colors.black54,
                                                      size: 25.0,
                                                    ),
                                                    label: const Text(
                                                      'Delete chat',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.black54,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                ListTile(
                                                  title: TextButton.icon(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) {
                                                            return TargetProfilePage(
                                                              targetUser: targetUser,
                                                              firebaseUser:
                                                              widget
                                                                  .firebaseUser,
                                                            );
                                                          },
                                                        ),
                                                      );
                                                    },
                                                    icon: ClipRRect(
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          100.0),
                                                      child: CachedNetworkImage(
                                                        imageUrl: targetUser
                                                            .profilepic
                                                            .toString(),
                                                        width: 25,
                                                        height: 25,
                                                        fit: BoxFit.fill,
                                                        errorWidget: (context,
                                                            url, error) =>
                                                            const CircleAvatar(
                                                              child: Icon(
                                                                CupertinoIcons
                                                                    .person,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                    label: const Text(
                                                      'View Profile',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.black54,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      leading: ClipRRect(
                                        borderRadius:
                                        BorderRadius.circular(100.0),
                                        child: CachedNetworkImage(
                                          imageUrl: targetUser.profilepic
                                              .toString(),
                                          width: 40,
                                          height: 40,
                                          errorWidget: (context, url, error) =>
                                              const CircleAvatar(
                                                child: Icon(CupertinoIcons.person),
                                              ),
                                        ),
                                      ),
                                      title: Text(targetUser.fullname ?? ''),
                                      subtitle: chatRoomModel.lastMessage
                                          ?.isNotEmpty ==
                                          true
                                          ? Text(
                                        chatRoomModel.lastMessage ?? '',
                                        maxLines: 1,
                                      )
                                          : Text(
                                        'Say Hi to your friend!',
                                        style: TextStyle(
                                          color: Colors.green[400],
                                        ),
                                      ),
                                        trailing: chatRoomModel.lastMsgtime != null
                                    ? Text(
                                    "${chatRoomModel.lastMsgtime!.toLocal().hour}:${chatRoomModel.lastMsgtime!.toLocal().minute}",
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                )
                                : Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade400,
                                            borderRadius: BorderRadius.circular(10)
                                          ),
                                        )

                            ),
                                  ),
                                );
                              } else {
                                return Container();
                              }
                            } else {
                              return buildShimmerLoadingTile();
                            }
                          },
                        );
                      },
                    );
                  }
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                } else {
                  return const Center(
                    child: Text("No chats"),
                  );
                }
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          CupertinoPageRoute(builder: (BuildContext context) {
            return SearchPage(
              userModel: widget.userModel,
              firebaseUser: widget.firebaseUser,
            );
          }),
        ),
        child: const Icon(Icons.add),
        backgroundColor: Colors.green[400],
      ),
    );
  }
}
