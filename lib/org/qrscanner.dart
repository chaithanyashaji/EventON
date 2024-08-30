import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRPage extends StatefulWidget {
  final String eventId; // Add this to receive the event ID

  QRPage({Key? key, required this.eventId}) : super(key: key);

  @override
  State<QRPage> createState() => _QRPageState();
}

class _QRPageState extends State<QRPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  bool isProcessing = false; // Flag to prevent multiple scans

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.resumeCamera();
    } else if (Platform.isIOS) {
      controller?.resumeCamera();
    }
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No Permission')),
      );
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!isProcessing) {
        setState(() {
          result = scanData;
          isProcessing = true; // Set processing flag to true
        });

        if (result != null && result!.code != null) {
          String code = result!.code!;
          print('Scanned Code: $code');
          controller.pauseCamera();
          getDetailsOfScanned(context, code);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 250.0
        : 300.0;

    return Scaffold(
      appBar: AppBar(
        title: Text('QR Scanner'),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.blueAccent,
                borderRadius: 5,
                borderLength: 15,
                borderWidth: 10,
                cutOutSize: scanArea,
              ),
              onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void getDetailsOfScanned(BuildContext context, String code) {
    final FirebaseFirestore db = FirebaseFirestore.instance;

    // Check if the scanned code exists in the users collection
    db.collection('users').doc(code).get().then((DocumentSnapshot ds) {
      if (ds.exists) {
        // The user exists; now check the REGISTRATIONS collection
        db.collection("REGISTRATIONS")
            .where("id", isEqualTo: code)
            .where("eventId", isEqualTo: widget.eventId) // Ensure correct field name
            .get()
            .then((QuerySnapshot querySnapshot) {
          if (querySnapshot.docs.isNotEmpty) {
            for (var document in querySnapshot.docs) {
              db.collection("REGISTRATIONS")
                  .doc(document.id)
                  .set({"ScannedStatus": "YES"}, SetOptions(merge: true))
                  .then((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.green,
                    content: Text(
                      "Scanned Successfully",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              });
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: Colors.red,
                content: Text(
                  "No matching registration found for this event",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            );
          }
          setState(() {
            isProcessing = false; // Reset processing flag after operation
          });
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                "Error: $error",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
          setState(() {
            isProcessing = false; // Reset processing flag on error
          });
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              "Ticket is Invalid",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
        setState(() {
          isProcessing = false; // Reset processing flag if ticket is invalid
        });
      }
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Error: $error",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
      setState(() {
        isProcessing = false; // Reset processing flag on error
      });
    });
  }
}
