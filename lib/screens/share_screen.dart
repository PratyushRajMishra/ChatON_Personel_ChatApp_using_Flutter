import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class SharePage extends StatefulWidget {
  const SharePage({super.key});

  @override
  State<SharePage> createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Share"),
        backgroundColor: Colors.blueGrey,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          // Wrap the Column with Center
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Center the content vertically
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Center the content horizontally
              children: [
                Image.asset(
                  "assets/splash.png",
                  width: 100,
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  'Version 1.0.0',
                  style: TextStyle(color: Colors.black54, letterSpacing: 0.5),
                ),
                const SizedBox(
                  height: 30,
                ),
                const Center(
                  child: Text(
                    'Share ChatON to everyone from here!',
                    style: TextStyle(color: Colors.black45, fontSize: 15),
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue.shade600,
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () {
                    Share.share('https://drive.google.com/file/d/1epwKL8sonX6Oip16xPF0kjqY3HPIRuyy/view?usp=drive_link');
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Share ChatON'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
