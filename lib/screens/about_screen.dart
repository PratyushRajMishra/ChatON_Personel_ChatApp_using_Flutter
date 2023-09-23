import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: Colors.blueGrey,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
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
                  style: TextStyle(
                      color: Colors.black54, letterSpacing: 0.5, fontSize: 15),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Chat',
                      style: TextStyle(
                          fontSize: 30,
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5),
                    ),
                    Text(
                      'ON',
                      style: TextStyle(
                          fontSize: 30,
                          color: Colors.lightGreen,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.all(30.0),
                  child: Text(
                    '"ChatON" is a user-friendly messaging platform designed to connect people seamlessly. With a sleek and intuitive interface, '
                    'it offers real-time communication through text, voice, and video chat. Stay connected with friends, family, and colleagues '
                    'effortlessly, no matter the distance. Our app ensures privacy and security with end-to-end encryption, and '
                    'it is packed with features like group chats, multimedia sharing, and customizable themes. '
                    'Chat App is your go-to solution for modern, reliable, and enjoyable conversations. Join millions of users worldwide and experience '
                    'the future of communication today.'
                    'Whether you are connecting with friends, family, or colleagues, ChatApp empowers users to stay in touch with loved '
                    'ones and collaborate with colleagues efficiently. Its commitment to user privacy and security ensures that '
                    'your conversations are kept safe and confidential.',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),

                Divider(),
                SizedBox(
                  height: 25,
                ),
                const Text(
                  'Developer: Pratyush Mishra',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.blueGrey),
                ),
                const Text(
                  'pratyushrajmishra70@gmail.com',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                ),
                const Text(
                  '+919454969946',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                ),
                const Text(
                  'Gorakhpur, Uttar Pradesh, India',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                ),
                const Text(
                  'Pincode- 273001',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                ),
                 const SizedBox(
                  height: 40,
                ),
                SizedBox(
                  height: 40,
                  width: 200,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Share.share('https://drive.google.com/file/d/1epwKL8sonX6Oip16xPF0kjqY3HPIRuyy/view?usp=drive_link');
                    },
                    icon: const Icon(
                      Icons.share_outlined,
                      color: Colors.black,
                    ),
                    label: const Text(
                      'Share ChatON',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5),
                    ),
                    style: ElevatedButton.styleFrom(
                        side: BorderSide.none,
                        backgroundColor: Colors.lightGreenAccent.shade200,
                        shape: const StadiumBorder()),
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
