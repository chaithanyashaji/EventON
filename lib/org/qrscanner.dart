import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScanner extends StatefulWidget {
  QRScanner({Key? key}) : super(key: key);

  @override
  State<QRScanner> createState() => _QRPageState();
}

class _QRPageState extends State<QRScanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

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
      setState(() {
        result = scanData;
        if (result != null && result!.code != null) {
          String code = result!.code!;
          print('Scanned Code: $code');
          controller.pauseCamera();
          getDetailsOfScanned(context, code);
          controller.resumeCamera();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
        MediaQuery.of(context).size.height < 400)
        ? 250.0
        : 300.0;

    return Scaffold(
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
}

void getDetailsOfScanned(BuildContext context, String code) {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  // Check if the scanned code exists in the REGISTRATIONS collection as a document ID
  db.collection('REGISTRATIONS').doc(code).get().then((DocumentSnapshot ds) {
    if (ds.exists) {
      // The document with the scanned code as the ID exists in the REGISTRATIONS collection
      db.collection("REGISTRATIONS")
          .doc(code)
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
    } else {
      // No document with the scanned code as the ID exists in the REGISTRATIONS collection
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
  });
}

