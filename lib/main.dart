
import 'package:chaton/models/FirebaseHelper.dart';
import 'package:chaton/models/UserModel.dart';
import 'package:chaton/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/main.dart';
import 'package:uuid/uuid.dart';

import 'firebase_options.dart';
import 'models/ChatRoomModel.dart';


var uuid= const Uuid();
late final ChatRoomModel chatroom;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    // Not logged in
    UserModel? thisUserModel = await FirebaseHelper.getUserModelById(currentUser.uid);

    if (thisUserModel != null) {
      runApp(
        MyAppLoggedIn(userModel: thisUserModel, firebaseUser: currentUser),
      );
    } else {
      runApp(const MyApp());
    }
  } else {
    // Logged in
    runApp(const MyApp());
  }
}


class MyAppLoggedIn extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;

  const MyAppLoggedIn({super.key, required this.userModel, required this.firebaseUser,});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(userModel: userModel, firebaseUser: firebaseUser, ),
    );
  }
}

