import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool notification_status = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: Colors.blueGrey,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Image.asset(
                    "assets/splash.png",
                    width: 75,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    'Version 1.0.0',
                    style: TextStyle(color: Colors.black54, letterSpacing: 0.5),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(15.0),
                    child: SizedBox(
                      height: 60,
                      child: Center(
                        child: Text(
                          'All types of notifications show here including system notification, chat and update notifications.',
                          style: TextStyle(color: Colors.black45, fontSize: 15),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Divider(),
                  const SizedBox(
                    height: 10,
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.black,
                      size: 25,
                    ),
                    title: const Text(
                      'Notifications',
                      style: TextStyle(fontSize: 18, letterSpacing: 0.5),
                    ),
                    trailing: Switch(
                      activeColor: Colors.black,
                      value: notification_status,
                      onChanged: (value) {
                        log("VALUE : $value");
                        setState(() {
                          notification_status = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(80.0),
                    child: Text(
                      notification_status ? 'No Notifications' : 'Turn ON Notifications',
                      style: const TextStyle(
                          fontSize: 17,
                          color: Colors.black54,
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.w500),
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
