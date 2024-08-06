import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'dart:io';

import 'package:qr_code_scanner/qr_code_scanner.dart';

class qrpage extends StatefulWidget {
  qrpage({Key? key}) : super(key: key);

  @override
  State<qrpage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<qrpage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.resumeCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    controller!.resumeCamera();
    // log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        print(result!.code.toString() + "sddaaaas");
        try {
          controller.pauseCamera();
          getDetailsOfScanned(
            context,
            result!.code.toString(),
          );
          controller.resumeCamera();
        } catch (e) {
          const snackBar = SnackBar(
              backgroundColor: Colors.red,
              duration: Duration(milliseconds: 3000),
              content: Text(
                "Invalid",
                textAlign: TextAlign.center,
                softWrap: true,
                style: TextStyle(color: Colors.white),
              ));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          controller.pauseCamera();

          ///Alert
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
                  cutOutSize: scanArea),
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
  DateTime todayTime = DateTime.now();
  final FirebaseFirestore db = FirebaseFirestore.instance;
  print("ksdk" + code);

  db
      .collection('users')
      .doc(code.toString())
      .snapshots()
      .listen((DocumentSnapshot ds) {
    print("asbjhasd" + "R" + code.toString());
    if (ds.exists) {
      Map<dynamic, dynamic> map = ds.data() as Map;
      db
          .collection("REGISTRATIONS")
          .where("id", isEqualTo: code.toString())
          .get()
          .then((value) {
        if (value.docs.isNotEmpty) {
          for (var element in value.docs) {
            db
                .collection("REGISTRATIONS")
                .doc(element.id)
                .set({"scanned_status": "YES"}, SetOptions(merge: true));
          }

          const snackBar = SnackBar(
              backgroundColor: Colors.red,
              duration: Duration(milliseconds: 3000),
              content: Text(
                "Scanned Succesfully",
                textAlign: TextAlign.center,
                softWrap: true,
                style: TextStyle(color: Colors.white),
              ));
        }
      });
    } else {
      const snackBar = SnackBar(
          backgroundColor: Colors.red,
          duration: Duration(milliseconds: 3000),
          content: Text(
            "Ticket is Invalid",
            textAlign: TextAlign.center,
            softWrap: true,
            style: TextStyle(color: Colors.white),
          ));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  });
}
