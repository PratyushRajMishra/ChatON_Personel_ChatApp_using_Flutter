import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/UserModel.dart';

class SecurityPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const SecurityPage(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  late TextEditingController emailController;
  late TextEditingController newpasswordController;




  @override
  void initState() {
    super.initState();

    // Initialize controllers with the existing user data
    emailController =
        TextEditingController(text: widget.userModel.email.toString());
   newpasswordController=
        TextEditingController();
  }

  @override
  void dispose() {
    // Dispose of the controllers when the widget is disposed
    emailController.dispose();
    newpasswordController.dispose();
    super.dispose();
  }

  void changeEmail() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
            child: Column(
              children: [
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.person,
                      color: Colors.blue,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.blue, width: 1.0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 1.0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    label: const Text(
                      'Email',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    side: BorderSide.none,
                    backgroundColor: Colors.lightGreenAccent.shade200,
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () {},
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  void changePassword() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
            child: Column(
              children: [
                TextFormField(
                  controller: newpasswordController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.password_sharp,
                      color: Colors.blue,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                      const BorderSide(color: Colors.blue, width: 1.0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                      const BorderSide(color: Colors.grey, width: 1.0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    label: const Text(
                      'New Password',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    side: BorderSide.none,
                    backgroundColor: Colors.lightGreenAccent.shade200,
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () {},
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void deleteAccount() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          title:  Text("Delete ${widget.userModel.fullname} ?",),
          content: const Text(
            'This account is permanently deleted, this messages and media are also deleted permanently.',
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

                });
              },
              child: const Text(
                'Delete Account',
                style: TextStyle(fontSize: 17, color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy and Security"),
        backgroundColor: Colors.blueGrey,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 10.0),
              child: Column(
                children: [
                  ListTile(
                    onTap: () {
                      changeEmail();
                    },
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.grey.withOpacity(0.1)),
                      child: const Icon(
                        Icons.email_outlined,
                        color: Colors.black,
                      ),
                    ),
                    title: const Text('Change Email'),
                    subtitle: Text(
                      'Changing your email id will get back to login page',
                      style: TextStyle(fontSize: 12),
                    ),
                    trailing: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.grey.withOpacity(0.1)),
                      child: const Icon(
                        Icons.navigate_next,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 10,
                  ),
                  ListTile(
                    onTap: () {
                      changePassword();
                    },
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.grey.withOpacity(0.1)),
                      child: const Icon(
                        Icons.password_outlined,
                        color: Colors.black,
                      ),
                    ),
                    title: const Text('Change Password'),
                    subtitle: Text(
                      'Changing your password will get back to login page',
                      style: TextStyle(fontSize: 12),
                    ),
                    trailing: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.grey.withOpacity(0.1)),
                      child: const Icon(
                        Icons.navigate_next,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 10,
                  ),
                  ListTile(
                    onTap: () {
                      deleteAccount();
                    },
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.grey.withOpacity(0.1)),
                      child: const Icon(
                        Icons.delete_forever_outlined,
                        color: Colors.red,
                      ),
                    ),
                    title: const Text('Delete Account'),
                    subtitle: Text(
                      'The account will be deleted from ChatON and all your devices',
                      style: TextStyle(fontSize: 12),
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