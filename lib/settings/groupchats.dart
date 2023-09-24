import 'package:flutter/material.dart';

class GroupChatsPage extends StatefulWidget {
  const GroupChatsPage({Key? key}) : super(key: key);

  @override
  State<GroupChatsPage> createState() => _GroupChatsPageState();
}

class _GroupChatsPageState extends State<GroupChatsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Groups"),
        backgroundColor: Colors.blueGrey,
        elevation: 0,
      ),
      body: const SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center vertically
            children: [
              Text(
                "No groups available",
                style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500), // Adjust the font size as needed
              ),
            ],
          ),
        ),
      ),
    );
  }
}
