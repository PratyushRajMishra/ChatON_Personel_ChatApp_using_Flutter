import 'package:flutter/material.dart';
class StoragePage extends StatefulWidget {
  const StoragePage({super.key});

  @override
  State<StoragePage> createState() => _StoragePageState();
}

class _StoragePageState extends State<StoragePage> {

  void networkUsage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          title:  const Text("Network Usage",),
          content: const Text(
            'Stay in set as default for better performance using ChatON.',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              child: const Text(
                'Cancel',
                style: TextStyle(fontSize: 15, color: Colors.black),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                side: BorderSide.none,
                backgroundColor: Colors.green.shade600,
                shape: const StadiumBorder(),
              ),
              onPressed: ()  {
                setState(() {
                  Navigator.pop(context);

                });
              },
              child: const Text(
                'Set as default',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

          ],
        );
      },
    );
  }


  void storageUsage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          title:  const Text("Storage Usage",),
          content: const Text(
            'Stay in set as default for better performance using ChatON.',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              child: const Text(
                'Cancel',
                style: TextStyle(fontSize: 15, color: Colors.black),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                side: BorderSide.none,
                backgroundColor: Colors.blue.shade600,
                shape: const StadiumBorder(),
              ),
              onPressed: ()  {
                setState(() {
                  Navigator.pop(context);

                });
              },
              child: const Text(
                'Set as default',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

          ],
        );
      },
    );
  }

  void resetSettings() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          title:  const Text("Are you sure want to reset settings?", style: TextStyle(fontSize: 18),),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              child: const Text(
                'Cancel',
                style: TextStyle(fontSize: 15, color: Colors.black),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                side: BorderSide.none,
                backgroundColor: Colors.red.shade600,
                shape: const StadiumBorder(),
              ),
              onPressed: ()  {
                setState(() {
                  Navigator.pop(context);

                });
              },
              child: const Text(
                'Reset',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
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
        title: Text("Data and Storage"),
        backgroundColor: Colors.blueGrey,
        elevation: 0,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Column(
              children: [
                ListTile(
                  onTap: () {
                    networkUsage();
                  },
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.grey.withOpacity(0.1)),
                    child: const Icon(
                      Icons.data_saver_off_outlined,
                      color: Colors.black,
                    ),
                  ),
                  title: const Text("Network usage"),
                  subtitle: Text(
                    'Network usage is currently set on default',
                    style: TextStyle(fontSize: 12),
                  ),
                ),

                SizedBox(height: 5,),
                ListTile(
                  onTap: () {
                    storageUsage();
                  },
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.grey.withOpacity(0.1)),
                    child: const Icon(
                      Icons.storage_outlined,
                      color: Colors.black,
                    ),
                  ),
                  title: const Text("Storage usage"),
                  subtitle: Text(
                    'Storage usage is currently set on default',
                    style: TextStyle(fontSize: 12),
                  ),
                ),

                SizedBox(height: 5,),
                ListTile(
                  onTap: () {
resetSettings();
                  },
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.grey.withOpacity(0.1)),
                    child: const Icon(
                      Icons.cached,
                      color: Colors.black,
                    ),
                  ),
                  title: const Text("Reset setting"),
                  subtitle: Text(
                    'All the settings are reset on default.',
                    style: TextStyle(fontSize: 12),
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
