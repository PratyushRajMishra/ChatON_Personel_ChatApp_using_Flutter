import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../models/UIHelper.dart';
import '../models/UserModel.dart';

class UpdateProfilePage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const UpdateProfilePage(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  bool isEditable = false;
  File? imageFile;

  late TextEditingController fullNameController;
  late TextEditingController mobileController;
  late TextEditingController aboutController;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with the existing user data
    fullNameController = TextEditingController(text: widget.userModel.fullname.toString());
    mobileController = TextEditingController(text: widget.userModel.mobile.toString());
    aboutController = TextEditingController(text: widget.userModel.about.toString());
  }

  // ... Rest of your code ...

  @override
  void dispose() {
    // Dispose of the controllers when the widget is disposed
    fullNameController.dispose();
    mobileController.dispose();
    aboutController.dispose();
    super.dispose();
  }


  void selectImage(ImageSource source) async {
    XFile? pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      cropImage(pickedFile);
    }
  }

  void cropImage(XFile file) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage(
        sourcePath: file.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 10);
    if (croppedImage != null) {
      setState(() {
        imageFile = File(croppedImage.path);
      });
    }
  }

  void showPhotoOptions() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Change profile picture'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    selectImage(ImageSource.gallery);
                  },
                  leading: Icon(Icons.photo),
                  title: Text('Select from gallery'),
                ),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    selectImage(ImageSource.camera);
                  },
                  leading: Icon(Icons.camera_alt),
                  title: Text('Take a photo'),
                )
              ],
            ),
          );
        });
  }

  Future<void> dataUpdate(BuildContext context) async {
    // Show a loading indicator
    UIHelper.showLoadingDialog(context, "Updating..");

    // Upload the image and get the download URL
    UploadTask uploadTask = FirebaseStorage.instance
        .ref("profilepictures")
        .child(widget.userModel.uid.toString())
        .putFile(imageFile!);
    TaskSnapshot snapshot = await uploadTask;
    String? imageUrl = await snapshot.ref.getDownloadURL();

    // Get updated data from text controllers
    final updatedFullName = fullNameController.text.trim();
    final updatedMobile = mobileController.text.trim();
    final updatedAbout = aboutController.text.trim();

    try {
      await FirebaseFirestore.instance.collection('users').doc(widget.firebaseUser.uid).update({
        'fullname': updatedFullName,
        'mobile': updatedMobile,
        'about': updatedAbout,
        'profilepic': imageUrl,
        // Add other fields you want to update
      });

      // Close the CircularProgressIndicator dialog
      Navigator.pop(context);

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully.'),
          backgroundColor: Colors.black,
          action: SnackBarAction(
            label: 'Ok',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    } catch (error) {
      // Handle errors
      // Close the CircularProgressIndicator dialog
      Navigator.pop(context);

      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }



  void showMessage() {
    final snackBar = SnackBar(
      content: const Text("Email can't change here."),
      action: SnackBarAction(
        label: 'Ok',
        textColor: Colors.white,
        onPressed: () {},
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 50),
              child: Column(
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100.0),
                        child:
                            imageFile != null // Check if imageFile is not null
                                ? Image.file(
                                    // Display the cropped image if available
                                    imageFile!,
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.fill,
                                  )
                                : CachedNetworkImage(
                                    // Display the network image if imageFile is null
                                    imageUrl:
                                        widget.userModel.profilepic.toString(),
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.fill,
                                    errorWidget: (context, url, error) =>
                                        const CircleAvatar(
                                      child: Icon(CupertinoIcons.person),
                                    ),
                                  ),
                      ),
                      Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: Colors.lightGreenAccent.shade200,
                            ),
                            child: IconButton(
                                onPressed: () {
                                  showPhotoOptions();
                                },
                                icon: const Icon(
                                  Icons.camera_alt_outlined,
                                  color: Colors.black,
                                  size: 20,
                                )),
                          )),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 50),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () {
                            if (!isEditable) {
                              showMessage();
                            }
                          },
                          child: IgnorePointer(
                            ignoring: !isEditable,
                            child: TextFormField(
                              readOnly: !isEditable,
                              initialValue: widget.userModel.email
                                  .toString(), // Replace with actual email
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.mail,
                                  color: Colors.blue,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.grey, width: 1.0),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.grey, width: 1.0),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                labelText: 'Email',
                                labelStyle: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                                suffixIcon: isEditable
                                    ? IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () {
                                          setState(() {
                                            isEditable = !isEditable;
                                          });
                                        },
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          controller: fullNameController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.person,
                              color: Colors.blue,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.blue, width: 1.0),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.grey, width: 1.0),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            label: const Text(
                              'Name',
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          controller: mobileController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.phone,
                              color: Colors.blue,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.blue, width: 1.0),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.grey, width: 1.0),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            label: const Text(
                              'Mobile',
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          controller: aboutController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.info_outlined,
                              color: Colors.blue,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.blue, width: 1.0),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.grey, width: 1.0),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            label: const Text(
                              'About',
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                        SizedBox(
                          height: 40,
                          width: 150,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  side: BorderSide.none,
                                  backgroundColor:
                                      Colors.lightGreenAccent.shade200,
                                  shape: const StadiumBorder()),
                              onPressed: () {
                                dataUpdate;
                              },
                              child: const Text(
                                'Save changes',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5),
                              )),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}