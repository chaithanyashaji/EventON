import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:universe2024/Utiles/app_styles.dart';  // Adjust as per your project

class QrGenerationScreen extends StatelessWidget {
  final String id;

  QrGenerationScreen({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,  // Set the background color to black
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),  // Add space between QR code and icon
            Icon(
              Icons.confirmation_num_outlined,
              color: Colors.white,
              size: 60,  // Larger icon size for better visibility
            ),
            Text(
              'Here is Your Ticket!!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,  // Slightly larger font size for emphasis
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,  // Add some letter spacing
              ),
            ),
            SizedBox(height: 20),  // Add space between text and QR code
            Container(
              width: 220,  // Adjust width as needed
              height: 220, // Adjust height as needed
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.4),
                    spreadRadius: 3,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: QrImageView(
                  data: id,
                  version: QrVersions.auto,
                  size: 200,  // Size of the QR code
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,  // QR code color
                ),
              ),
            ),

            SizedBox(height: 20),  // Add space between icon and additional text
            Text(
              'Scan to Verify',
              style: TextStyle(
                color: Colors.white70,  // Slightly lighter text color
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
