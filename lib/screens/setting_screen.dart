import 'package:cached_network_image/cached_network_image.dart';
import 'package:chaton/screens/about_screen.dart';
import 'package:chaton/screens/notifications_screen.dart';
import 'package:chaton/screens/update_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/UserModel.dart';
class SettingPage extends StatefulWidget {

  final UserModel userModel;
  final User firebaseUser;

  const SettingPage({super.key, required this.userModel, required this.firebaseUser,});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        elevation: 0,
        leading: const BackButton(color: Colors.black,),
        title: const Text('Settings', style: TextStyle(color: Colors.black),),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: IconButton(onPressed: () {}, icon: const Icon(Icons.dark_mode_outlined, color: Colors.black, size: 25,)),
          )
        ],
      ),

      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              children: [
                Stack(
                  children: [
                    ClipRRect(
                    borderRadius: BorderRadius.circular(100.0),
                    child: CachedNetworkImage(
                      imageUrl: widget.userModel.profilepic.toString(),
                      width: 150,
                      height: 150,
                      fit: BoxFit.fill,
                      errorWidget: (context, url, error) => const CircleAvatar(
                        child: Icon(CupertinoIcons.person),
                      ),
                    ),
                  ),
                    Positioned(bottom: 0,
                        right: 0,
                        child: Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color:  Colors.lightGreenAccent.shade200,
                          ),
                          child: IconButton(onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) {
                                return UpdateProfilePage(userModel: widget.userModel, firebaseUser: widget.firebaseUser,);
                              }),
                            );
                          }, icon: const Icon(Icons.edit, color: Colors.black, size: 20,)),
                        ))
          ],
                ),

                const SizedBox(height: 20,),

                Text(
                  widget.userModel.fullname.toString(),
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5),
                ),
                const SizedBox(height: 5,),
                Text(
                  widget.userModel.email.toString(),
                  style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5),
                ),
                const SizedBox(height: 25,),
                SizedBox(
                  height: 40,
                  width: 150,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    side: BorderSide.none,
                    backgroundColor: Colors.lightGreenAccent.shade200,
                    shape: const StadiumBorder(),
                  ),
                  onPressed: ()  {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return UpdateProfilePage(userModel: widget.userModel, firebaseUser: widget.firebaseUser);
                      }),
                    );
                  },
                  child: const Text(
                    'Edit Profile',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),


                ),
                const SizedBox(height: 30),
                const Divider(),
                const SizedBox(height: 10),
                  ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) {
                          return  const NotificationsPage();
                        }),
                      );
                    },
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.grey.withOpacity(0.1)
                      ),
                      child: const Icon(Icons.notifications_outlined, color: Colors.black,),
                    ),

                    title: const Text('Notifications'),
                    trailing: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.grey.withOpacity(0.1)
                      ),
                      child: const Icon(Icons.navigate_next, color: Colors.black,),
                    ),
                  ),

                ListTile(
                  onTap: () {},
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.grey.withOpacity(0.1)
                    ),
                    child: const Icon(Icons.privacy_tip_outlined, color: Colors.black,),
                  ),

                  title: const Text('Privacy and Security'),
                  trailing: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.grey.withOpacity(0.1)
                    ),
                    child: const Icon(Icons.navigate_next, color: Colors.black,),
                  ),
                ),

                ListTile(
                  onTap: () {},
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.grey.withOpacity(0.1)
                    ),
                    child: const Icon(Icons.sd_storage_outlined, color: Colors.black,),
                  ),

                  title: const Text('Data and Storage'),
                  trailing: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.grey.withOpacity(0.1)
                    ),
                    child: const Icon(Icons.navigate_next, color: Colors.black,),
                  ),
                ),

                const SizedBox(height: 10,),
                const Divider(),
                const SizedBox(height: 10,),

                ListTile(
                  onTap: () {},
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.grey.withOpacity(0.1)
                    ),
                    child: const Icon(Icons.group_outlined, color: Colors.black,),
                  ),

                  title: const Text('Group chats'),
                  trailing: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.grey.withOpacity(0.1)
                    ),
                    child: const Icon(Icons.navigate_next, color: Colors.black,),
                  ),
                ),

                ListTile(
                  onTap: () {},
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.grey.withOpacity(0.1)
                    ),
                    child: const Icon(Icons.block_outlined, color: Colors.black,),
                  ),

                  title: const Text('Blocked Users'),
                  trailing: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.grey.withOpacity(0.1)
                    ),
                    child: const Icon(Icons.navigate_next, color: Colors.black,),
                  ),
                ),

                ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return  const AboutPage();
                      }),
                    );
                  },
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.grey.withOpacity(0.1)
                    ),
                    child: const Icon(Icons.menu_book_outlined, color: Colors.black,),
                  ),

                  title: const Text('About ChatON'),
                  trailing: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.grey.withOpacity(0.1)
                    ),
                    child: const Icon(Icons.navigate_next, color: Colors.black,),
                  ),
                ),

                const SizedBox(height: 40,),
                SizedBox(
                  height: 45,
                  width: 225,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          side: BorderSide.none,
                          backgroundColor: Colors.red,
                          shape: const StadiumBorder()
                      ),
                      onPressed: () {},
                      child: Text('Logout ${widget.userModel.fullname}', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 1.0),)
                  ),
                ),

              ],
            ),
          ),
        ),
    ),
    );
  }
}
