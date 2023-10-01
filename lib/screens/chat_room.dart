import 'dart:developer';
import 'dart:io'; // Import 'File' from 'dart:io'

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chaton/main.dart';
import 'package:chaton/models/MessageModel.dart';
import 'package:chaton/screens/targetProfile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

import '../models/ChatRoomModel.dart';
import '../models/FullScreenImage.dart';
import '../models/UserModel.dart';
import '../models/FullScreenVideoPlayer.dart';

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
  VideoPlayerController? _videoPlayerController;

  @override
  @override
  void initState() {
    super.initState();
    // Retrieve the message corresponding to the video from Firestore or your data source
    // Replace 'yourMessageId' with the actual ID of the video message
    FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(widget.chatroom.chatroomid)
        .collection("messages")
        .doc('yourMessageId') // Replace with the actual message ID
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        // Create a MessageModel object from the document data
        MessageModel videoMessage = MessageModel.fromMap(
          documentSnapshot.data() as Map<String, dynamic>,
        );

        if (videoMessage.fileType == 'video') {
          _videoPlayerController = VideoPlayerController.network(
            videoMessage.fileUrl.toString(),
          )..initialize().then((_) {
              setState(() {});
            });
        }
      }
    });
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

  TextEditingController messageController = TextEditingController();

  void sendMessage(String textMessage, String fileUrl, String fileType) async {
    try {
      String lastMessageText = ""; // Initialize lastMessageText

      // Create a message with the appropriate fileType and text
      MessageModel newMessage = MessageModel(
        messageid: uuid.v1(),
        sender: widget.userModel.uid,
        createdon: DateTime.now(),
        text:
            textMessage, // Set text for text messages, or leave it empty for files
        seen: false,
        fileType:
            fileType, // Set 'image' for images, 'video' for videos, or leave it empty for text
        fileUrl: fileUrl, // Set the actual file URL here for images and videos
      );

      // Update lastMessageText based on the message type
      if (fileType == 'image' || fileType == 'video') {
        lastMessageText = 'File';
      } else {
        lastMessageText = textMessage;
      }

      // Store the message in Firestore
      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .collection("messages")
          .doc(newMessage.messageid)
          .set(newMessage.toMap());

      // Update the chatroom with the last message and time
      widget.chatroom.lastMessage =
          lastMessageText; // Set the appropriate message text
      widget.chatroom.lastMsgtime = DateTime.now();
      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .set(widget.chatroom.toMap());

      print("Message Sent!");
    } catch (e) {
      // Handle any errors that may occur during message sending
      print("Error sending message: $e");
    }
  }

  Future<void> pickCamera() async {
    XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      // Get the picked image file
      File imageFile = File(pickedFile.path);

      // Upload the image to Firebase Storage
      try {
        final storageRef = FirebaseStorage.instance.ref().child(
            'chat_files/${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}');
        final uploadTask = storageRef.putFile(imageFile);

        // Monitor the upload progress (optional)
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          double progress = snapshot.bytesTransferred / snapshot.totalBytes;
          print('Upload progress: $progress');
        });

        // Wait for the upload to complete
        await uploadTask;

        // Get the file URL
        final fileUrl = await storageRef.getDownloadURL();

        // Create a message for the image
        sendMessage("", fileUrl, 'image'); // Set an empty text for images

        print("Image Sent!");
      } catch (e) {
        // Handle any errors when uploading the image
        print("Error uploading image: $e");
      }
    }
  }

  Future<void> pickFile() async {
    try {
      final permissions = await [
        Permission.camera,
        Permission.storage, // Request storage permission as well
      ].request();

      if (permissions[Permission.camera]!.isGranted &&
          permissions[Permission.storage]!.isGranted) {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: [
            'mp4',
            'mov',
            'png',
            'jpg',
            'jpeg'
          ], // Specify allowed file extensions
        );

        if (result != null) {
          PlatformFile file = result.files.first;
          String fileType = '';

          if (file.extension == 'mp4' || file.extension == 'mov') {
            fileType = 'video';
          } else if (file.extension == 'png' ||
              file.extension == 'jpg' ||
              file.extension == 'jpeg') {
            fileType = 'image';
          }

          // Upload the picked file to Firebase Storage
          final storageRef = FirebaseStorage.instance.ref().child(
              'chat_files/${DateTime.now().millisecondsSinceEpoch}_${file.name}');
          final uploadTask = storageRef.putFile(File(file.path.toString()));

          // Monitor the upload progress (optional)
          uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
            double progress = snapshot.bytesTransferred / snapshot.totalBytes;
            print('Upload progress: $progress');
          });

          // Wait for the upload to complete
          await uploadTask;

          // Get the file URL
          final fileUrl = await storageRef.getDownloadURL();

          // Create a message based on file type
          MessageModel newMessage = MessageModel(
            messageid: uuid.v1(),
            sender: widget.userModel.uid,
            createdon: DateTime.now(),
            text: "", // Leave text empty for images and videos
            seen: false,
            fileType: fileType,
            fileUrl: fileUrl,
          );

          // Determine if it's an image or video and send accordingly
          if (fileType == 'image') {
            sendMessage("", fileUrl, 'image'); // Set an empty text for images
          } else if (fileType == 'video') {
            sendMessage("", fileUrl, 'video'); // Set an empty text for videos
          }

          print("File Sent!");
        }
      } else {
        // Handle permission denied
      }
    } catch (e) {
      // Handle any errors when picking and uploading files
      print("Error picking/uploading file: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
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
                child: Center(child: Text(widget.targetUser.fullname.toString())),
              ),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return TargetProfilePage(
                    targetUser: widget.targetUser,
                    firebaseUser: widget.firebaseUser,
                  );
                }));
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.call), // Add the call icon here
            onPressed: () {
              // Handle the call button press here
            },
          ),
        ],
      ),

      body: Container(
        decoration: BoxDecoration(
          color: Colors.green.shade50,
        ), // Replace with your desired background color
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
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

                              return buildMessageItem(currentMessage);
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
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    right: 75.0, left: 15.0, bottom: 15.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.blue.shade200, width: 2),
                    borderRadius: BorderRadius.all(Radius.circular(35.0)),
                  ),
                  padding:
                      EdgeInsets.only(left: 15, top: 2, bottom: 2, right: 4),
                  child: Row(
                    children: [
                      Flexible(
                        child: TextField(
                          controller: messageController,
                          maxLines: null,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Type your message...",
                          ),
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            pickFile();
                          },
                          icon: Icon(
                            Icons.photo_library,
                            color: Colors.black38,
                          )),
                      IconButton(
                          onPressed: () {
                            pickCamera();
                          },
                          icon: Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.black38,
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green.shade800,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
        onPressed: () {
          // Get the text message from the input field
          String textMessage = messageController.text.trim();

          // Check if the message is not empty
          if (textMessage.isNotEmpty) {
            // Initialize fileUrl and fileType to empty strings
            String fileUrl = '';
            String fileType = '';

            // Call the sendMessage function with the obtained values
            sendMessage(textMessage, fileUrl, fileType);

            // Clear the input field
            messageController.clear();
          }
        },
        child: Icon(
          Icons.send,
          color: Colors.white,
          size: 25,
        ), // Change the icon as needed
      ),
    );
  }

  Widget buildMessageItem(MessageModel message) {
    final isCurrentUser = message.sender == widget.userModel.uid;

    return Container(
      margin: EdgeInsets.only(
        top: 8.0,
        bottom: 8.0,
        left: isCurrentUser ? 100.0 : 8.0,
        right: isCurrentUser ? 8.0 : 100.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: isCurrentUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (message.fileType != null &&
                    (message.fileType == 'image' ||
                        message.fileType == 'video'))
                  buildMediaMessage(message)
                else
                  buildTextMessage(message),
                Text(
                  'Sent ${DateFormat('yyyy-MM-dd HH:mm').format(message.createdon!.toLocal())}',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                )
              ],
            ),
          ),
          if (!isCurrentUser) SizedBox() // Add an empty space for alignment
        ],
      ),
    );
  }

  Widget buildMediaMessage(MessageModel message) {
    if (message.fileType == 'image') {
      return GestureDetector(
        onTap: () {
          // Show the full-screen image dialog when the image is tapped
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return FullScreenImageDialog(imageUrl: message.fileUrl.toString());
            },
          );
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white, // Border color
              width: 3.0, // Border width
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: CachedNetworkImage(
              imageUrl: message.fileUrl.toString(),
              width: 175,
              height: 250,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => Center(
                child: Text(
                  'Error loading image',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ),
        ),
      );
    } else if (message.fileType == 'video') {
      return GestureDetector(
        onTap: () {
          // Show the video in full-screen mode when tapped
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => FullScreenVideoPlayer(
                videoUrl: message.fileUrl.toString(),
              ),
            ),
          );
        },
        child: buildVideoThumbnail(
          message.fileUrl.toString(),
        ), // Replace with actual video duration
      );
    }

    // Placeholder for unsupported file types (you can customize this)
    return Container(
      child: Text(
        "Unsupported file type: ${message.fileType}",
        style: TextStyle(color: Colors.red),
      ),
    );
  }

  Widget buildTextMessage(MessageModel message) {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: message.sender == widget.userModel.uid
            ? Colors.green[400]
            : Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        message.text.toString(),
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}

Widget buildVideoThumbnail(String videoUrl) {
  final videoPlayerController = VideoPlayerController.network(videoUrl);

  return FutureBuilder(
    future: videoPlayerController.initialize(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        final duration = videoPlayerController.value.duration;
        final durationText = _formatDuration(duration);

        return Container(
          width: 225,
          height: 350,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white, // Border color
              width: 3.0, // Border width
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10), // Make it circular
            child: Stack(
              alignment: Alignment.center,
              children: [
                VideoPlayer(videoPlayerController),
                Icon(
                  Icons.play_circle_fill,
                  size: 50,
                  color: Colors.white,
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      durationText,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      else {
        return Container(
          width: 225,
          height: 350,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white, // Border color
              width: 3.0, // Border width
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              CachedNetworkImage(
                imageUrl: videoUrl,
                width: 225,
                height: 350,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.play_circle_fill,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Icon(
                Icons.play_circle_fill,
                size: 50,
                color: Colors.white,
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Icon(
                      Icons.watch_later_outlined,
                      color: Colors.white,
                      size: 15,
                    )),
              ),
            ],
          ),
        );
      }
    },
  );
}

String _formatDuration(Duration duration) {
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}
