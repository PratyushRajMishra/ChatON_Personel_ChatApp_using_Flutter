import 'dart:developer';
import 'dart:io'; // Import 'File' from 'dart:io'
import 'dart:typed_data';

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
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';

import '../models/ChatRoomModel.dart';
import '../models/FullScreenImage.dart';
import '../models/UserModel.dart';
import '../models/FullScreenVideoPlayer.dart';
import 'package:path_provider/path_provider.dart';

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
    final PermissionStatus status = await Permission.camera.request();

    if (status.isGranted) {
      XFile? pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        // Get the picked image file
        File imageFile = File(pickedFile.path);

        // Compress the image
        Uint8List? compressedImageData = await FlutterImageCompress.compressWithFile(
          imageFile.path,
          minHeight: 1920,
          minWidth: 1080,
          quality: 20,
        );

        if (compressedImageData != null) {
          List<int> compressedImageBytes = compressedImageData.toList();

          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Row(
                  children: [
                    CircularProgressIndicator(), // Show a loading indicator
                    SizedBox(width: 20),
                    Text('Sending...'), // Show "Sending..." text
                  ],
                ),
              );
            },
            barrierDismissible: false, // Prevent dismissing the dialog
          );

          // Use a try-catch block to handle errors during the upload
          try {
            final storageRef = FirebaseStorage.instance.ref().child(
                'chat_files/${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}');
            final uploadTask = storageRef.putData(Uint8List.fromList(compressedImageBytes));

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
          } finally {
            // Close the "Sending" dialog
            Navigator.of(context).pop();
          }
        } else {
          // Handle the case where compression fails
          print("Image compression failed.");
        }
      }
    } else {
      // Handle permission denied.
      // You can show a message to the user or request permission again.
      print("Camera permission denied.");
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
            'jpeg',
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

          if (fileType == 'image') {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  content: Row(
                    children: [
                      CircularProgressIndicator(), // Show a loading indicator
                      SizedBox(width: 20),
                      Text('Sending...'), // Show "Sending..." text
                    ],
                  ),
                );
              },
              barrierDismissible: false, // Prevent dismissing the dialog
            );

            // Compress the image
            Uint8List? compressedImageData = await FlutterImageCompress.compressWithFile(
              file.path.toString(),
              minHeight: 1920,
              minWidth: 1080,
              quality: 20,
            );

            if (compressedImageData != null) {
              // Create a compressed image file
              File compressedImageFile = File('${file.path}_compressed.jpg');
              await compressedImageFile.writeAsBytes(compressedImageData);

              // Upload the compressed image to Firebase Storage
              final storageRef = FirebaseStorage.instance.ref().child(
                  'chat_files/${DateTime.now().millisecondsSinceEpoch}_${file.name}');
              final uploadTask = storageRef.putFile(compressedImageFile);

              // Monitor the upload progress (optional)
              uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
                double progress = snapshot.bytesTransferred / snapshot.totalBytes;
                print('Upload progress: $progress');
              });

              // Wait for the upload to complete
              await uploadTask;

              // Get the file URL
              final fileUrl = await storageRef.getDownloadURL();

              // Create a message for the compressed image
              sendMessage("", fileUrl, 'image'); // Set an empty text for images

              print("File Sent!");

              // Close the "Sending" dialog
              Navigator.of(context).pop();
            } else {
              // Handle the case where compression fails
              print("Image compression failed.");
              // Close the "Sending" dialog
              Navigator.of(context).pop();
            }
          } else if (fileType == 'video') {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  content: Row(
                    children: [
                      CircularProgressIndicator(), // Show a loading indicator
                      SizedBox(width: 20),
                      Text('Sending...'), // Show "Sending..." text
                    ],
                  ),
                );
              },
              barrierDismissible: false, // Prevent dismissing the dialog
            );

            final tempDir = await getTemporaryDirectory();
            final compressedFilePath =
                '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}_compressed.mp4';

            // Ensure file.path is not null before compressing
            if (file.path != null) {
              final mediaInfo = await VideoCompress.compressVideo(
                file.path!,
                quality: VideoQuality.LowQuality,
              );

              if (mediaInfo != null && mediaInfo.path != null) {
                final compressedVideoFile = File(mediaInfo.path!);
                final storageRef = FirebaseStorage.instance.ref().child(
                    'chat_files/${DateTime.now().millisecondsSinceEpoch}_${file.name}');
                final uploadTask = storageRef.putFile(compressedVideoFile);

                // Monitor the upload progress (optional)
                uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
                  double progress = snapshot.bytesTransferred / snapshot.totalBytes;
                  print('Upload progress: $progress');
                });

                // Wait for the upload to complete
                await uploadTask;

                // Get the file URL
                final fileUrl = await storageRef.getDownloadURL();

                // Create a message for the compressed video
                sendMessage("", fileUrl, 'video'); // Set an empty text for videos

                print("Video Sent!");

                // Close the "Sending" dialog
                Navigator.of(context).pop();
              } else {
                print("Compression failed.");
                // Close the "Sending" dialog
                Navigator.of(context).pop();
              }
            } else {
              print("File path is null.");
              // Close the "Sending" dialog
              Navigator.of(context).pop();
            }
          }
        }
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
                errorWidget: (context, url, error) => const CircleAvatar(
                  child: Icon(CupertinoIcons.person),
                ),
              ),
            ),
            const SizedBox(
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
            icon: const Icon(Icons.more_vert_rounded), // Add the call icon here
            onPressed: () {
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
                  padding: const EdgeInsets.symmetric(horizontal: 10),
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
                          return const Center(
                            child: Text("Something went wrong!!"),
                          );
                        } else {
                          return const Center(
                            child: Text("Say hi to your new friend!"),
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
              Padding(
                padding: const EdgeInsets.only(
                    right: 75.0, left: 15.0, bottom: 15.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.blue.shade200, width: 2),
                    borderRadius: const BorderRadius.all(Radius.circular(35.0)),
                  ),
                  padding:
                      const EdgeInsets.only(left: 15, top: 2, bottom: 2, right: 4),
                  child: Row(
                    children: [
                      Flexible(
                        child: TextField(
                          controller: messageController,
                          maxLines: null,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Type your message...",
                          ),
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            pickFile();
                          },
                          icon: const Icon(
                            Icons.photo_library,
                            color: Colors.black38,
                          )),
                      IconButton(
                          onPressed: () {
                            pickCamera();
                          },
                          icon: const Icon(
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
        child: const Icon(
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
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                )
              ],
            ),
          ),
          if (!isCurrentUser) const SizedBox() // Add an empty space for alignment
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
              errorWidget: (context, url, error) => const Center(
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
        style: const TextStyle(color: Colors.red),
      ),
    );
  }

  Widget buildTextMessage(MessageModel message) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: message.sender == widget.userModel.uid
            ? Colors.green[400]
            : Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        message.text.toString(),
        style: const TextStyle(color: Colors.white),
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
              color: Colors.white,
              width: 3.0,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              alignment: Alignment.center,
              children: [
                VideoPlayer(videoPlayerController),
                const Icon(
                  Icons.play_circle_fill,
                  size: 50,
                  color: Colors.white,
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      durationText,
                      style: const TextStyle(color: Colors.white),
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
              color: Colors.white,
              width: 3.0,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(
                Icons.play_circle_fill,
                size: 50,
                color: Colors.white,
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Icon(
                    Icons.watch_later_outlined,
                    color: Colors.white,
                    size: 15,
                  ),
                ),
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



