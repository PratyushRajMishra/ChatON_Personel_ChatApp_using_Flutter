import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class FullScreenImageDialog extends StatelessWidget {
  final String imageUrl;

  FullScreenImageDialog({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero, // Remove any padding around the dialog content
      backgroundColor: Colors.transparent, // Make the dialog background transparent
      child: Stack(
        children: [
          Container(
            width: double.infinity, // Make the dialog width full screen
            height: double.infinity, // Make the dialog height full screen
            child: PhotoView(
              imageProvider: NetworkImage(imageUrl),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2, // Adjust the max scale as needed
              backgroundDecoration: BoxDecoration(
                color: Colors.black, // Set the background color to black
              ),
            ),
          ),
          Positioned(
            top: 16, // Adjust the position of the back button as needed
            left: 16, // Adjust the position of the back button as needed
            child: IconButton(
              icon: Icon(
                Icons.close,
                color: Colors.white, // Set the icon color
                size: 32, // Set the icon size
              ),
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
            ),
          ),
        ],
      ),
    );
  }

  // Function to open the full-screen image dialog
  static void open(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return FullScreenImageDialog(imageUrl: imageUrl);
      },
    );
  }
}
