import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:universe2024/Utiles/app_styles.dart';


class QrGenerationScreen extends StatelessWidget {
  String id;
  QrGenerationScreen({Key? key,required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Styles.yellowColor,
            image: DecorationImage(
              image: AssetImage('assets/qrbg.png'),
              fit: BoxFit.contain,
              // Replace with your image asset
            ),
          ),


          child:Column(
            children: [

              Padding(
                padding:  EdgeInsets.only(left: 20,top:400),
                child: Container(
                  width: 190,
                  height: 190,
                  child: QrImageView(
                    padding:  EdgeInsets.all(10),
                    backgroundColor: Colors.white,
                    data: id,
                    version: QrVersions.auto,
                    size: 100,

                  ),
                ),
              )

            ],
          ),


        )
    );
  }
}