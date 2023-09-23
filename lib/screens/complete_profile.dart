import 'dart:developer';
import 'dart:io';

import 'package:chaton/models/UIHelper.dart';
import 'package:chaton/models/UserModel.dart';
import 'package:chaton/screens/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class CompleteProfile extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const CompleteProfile({super.key, required this.userModel, required this.firebaseUser});

  @override
  State<CompleteProfile> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {
  File? imageFile;
  TextEditingController fullNameController = TextEditingController();
  TextEditingController aboutController = TextEditingController();
  TextEditingController mobileController = TextEditingController();

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
            title: Text('Upload profile picture'),
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

  void checkValues() {
    String fullname = fullNameController.text.trim();
    String about = aboutController.text.trim();
    String mobile = mobileController.text.trim();
    if (fullname == ''|| about == '' || mobile == '' || imageFile == null) {
      UIHelper.shoeAlertDialog(context, "Incomplete Data", "Please fill all the fields and "
          "upload a profile picture");
    } else {
      uploadData();
    }
  }

  void uploadData() async {

    UIHelper.showLoadingDialog(context, "Set profile picture..");

    UploadTask uploadTask = FirebaseStorage.instance
        .ref("profilepictures")
        .child(widget.userModel.uid.toString())
        .putFile(imageFile!);

    TaskSnapshot snapshot = await uploadTask;

    String? imageUrl = await snapshot.ref.getDownloadURL();
    String? fullname = fullNameController.text.trim();
    String? about = aboutController.text.trim();
    String? mobile = mobileController.text.trim();

    widget.userModel.fullname = fullname;
    widget.userModel.about = about;
    widget.userModel.mobile = mobile;
    widget.userModel.profilepic = imageUrl;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userModel.uid)
        .set(widget.userModel.toMap()).then((value){
          log('Data uploaded!');
          Navigator.popUntil(context, (route) => route.isFirst);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context){
              return HomePage(userModel: widget.userModel, firebaseUser: widget.firebaseUser);
            }
            ),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[400],
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text('Complete Profile'),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Center(
            child: ListView(
              children: [
                SizedBox(
                  height: 50,
                ),
                CupertinoButton(
                  onPressed: () {
                    showPhotoOptions();
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.green[400],
                    radius: 90,
                    backgroundImage:
                        (imageFile != null) ? FileImage(imageFile!) : null,
                    child: (imageFile == null)
                        ? Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                TextField(
                  controller: fullNameController,
                  decoration: InputDecoration(labelText: 'Full name'),
                ),
                SizedBox(
                  height: 20,
                ),

                TextField(
                  controller: aboutController,
                  decoration: InputDecoration(labelText: 'About'),
                ),

                SizedBox(
                  height: 20,
                ),

                TextField(
                  controller: mobileController,
                  decoration: InputDecoration(labelText: 'Mobile no.'),
                ),


                SizedBox(
                  height: 60,
                ),

                CupertinoButton(
                    child: Text(
                      'SUBMIT',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    color: Colors.green[400],
                    onPressed: () {
                      checkValues();
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
