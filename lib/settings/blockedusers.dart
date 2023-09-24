import 'package:flutter/material.dart';
class BlockedUsersPage extends StatefulWidget {
  const BlockedUsersPage({super.key});

  @override
  State<BlockedUsersPage> createState() => _BlockedUsersPageState();
}

class _BlockedUsersPageState extends State<BlockedUsersPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Blocked Users"),
        backgroundColor: Colors.blueGrey,
        elevation: 0,
      ),

      body: const SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center vertically
            children: [
              Text(
                "No blocked users",
                style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500), // Adjust the font size as needed
              ),
            ],
          ),
        ),
      ),
    );
  }
}
