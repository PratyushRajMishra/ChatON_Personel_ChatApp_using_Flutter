import 'package:chaton/screens/home_screen.dart';
import 'package:chaton/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import 'firebase_options.dart';
import 'models/FirebaseHelper.dart';
import 'models/UserModel.dart';

var uuid= Uuid();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    UserModel? thisUserModel = await FirebaseHelper.getUserModelById(currentUser.uid);

    if (thisUserModel != null) {
      runApp(
        MyAppLoggedIn(userModel: thisUserModel, firebaseUser: currentUser),
      );
    } else {
      runApp(const MyApp());
    }
  } else {
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const GetMaterialApp(  // Replace MaterialApp with GetMaterialApp
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class MyAppLoggedIn extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;

  const MyAppLoggedIn({super.key, required this.userModel, required this.firebaseUser});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(  // Replace MaterialApp with GetMaterialApp
      debugShowCheckedModeBanner: false,
      home: HomePage(userModel: userModel, firebaseUser: firebaseUser),
    );
  }
}
