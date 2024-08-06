import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:flutter/material.dart';
import 'package:universe2024/Utiles/app_styles.dart';

import 'Messages.dart';

class chat extends StatefulWidget {
  const chat({super.key});

  @override
  State<chat> createState() => _chatState();
}

class _chatState extends State<chat> {
  late DialogFlowtter dialogFlowtter;
  final TextEditingController _controller=TextEditingController();

  List<Map<String, dynamic>> messages= [];


  @override
  void initState(){
     DialogFlowtter.fromFile().then((instance) => dialogFlowtter = instance);
     super.initState();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.bgColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0), // Adjust the height of the app bar as needed
        child: AppBar(
          backgroundColor: Colors.transparent, // Transparent background to show the gradient
          flexibleSpace: Container(
            padding: EdgeInsets.only(right: 40.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Styles.yellowColor, Styles.lblueColor,Styles.blueColor,], // Gradient colors
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(10), // Curved edges
              ),
            ),

            child:
            Row(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                Image.asset(
                  'assets/logowhite.png',
                  fit: BoxFit.fitHeight, // Adjust the fit as needed
                ),
                Text(
                    "Unibot",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,)// Title text color
                ),
              ],
            ),

          ),
        ),
        // Remove back button
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(child: MessagesScreen(messages:messages)),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8
              ),
               color: Styles.lyellow,
              child: Row(
                children: [
                  Expanded(child: TextField(
                    controller: _controller,
                    style: TextStyle(color: Styles.blueColor),
                  )),
                  IconButton(onPressed: (){
                    sendMessage(_controller.text);
                    _controller.clear();
                  }, icon: Icon(Icons.send))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
  sendMessage(String text)async{
    if(text.isEmpty){
      print('Message is empty');

    }
    else{
      setState((){
        addMessage(Message(text: DialogText(text:[text])),true);

      });

      DetectIntentResponse response = await dialogFlowtter.detectIntent(
          queryInput: QueryInput(text: TextInput(text:text)));
      if(response.message==null) return;
      setState(() {
        addMessage(response.message!);
      });
    }
  }
  addMessage(Message message,[bool isUserMessage=false]){
    messages.add({'message':message,
      'isUserMessage': isUserMessage
    });
  }
}


