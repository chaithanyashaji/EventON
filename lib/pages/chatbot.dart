import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:universe2024/Utiles/app_styles.dart';
import 'Messages.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  late DialogFlowtter dialogFlowtter;
  final TextEditingController _controller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> messages = [];

  List<String> eventNames = []; // List to hold event names dynamically fetched from Firestore

  @override
  void initState() {
    DialogFlowtter.fromFile().then((instance) => dialogFlowtter = instance);
    fetchEventNames(); // Fetch event names when the app starts
    super.initState();
  }

  // Fetch all event names from Firestore
  Future<void> fetchEventNames() async {
    QuerySnapshot querySnapshot = await _firestore.collection('events').get();
    setState(() {
      eventNames = querySnapshot.docs
          .map((doc) => doc['eventName'] as String) // Assuming 'eventName' is the field name in your Firestore
          .toList();
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.white, // Set the back button color to white
        ),
        flexibleSpace: Container(
          margin: EdgeInsets.only(left: 40, top: 45),
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(10),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "EON",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Image.asset(
                'assets/EventOn.png',
                height: 40,
                fit: BoxFit.fitHeight,
              ),
            ],
          ),
        ),
      ),

      body: Column(
        children: [
          Expanded(child: MessagesScreen(messages: messages)),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: Colors.black, // Changed to black
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(color: Colors.white), // Set text color to white
                  ),
                ),
                IconButton(
                  onPressed: () {
                    sendMessage(_controller.text);
                    _controller.clear();
                  },
                  icon: Icon(Icons.send, color: Colors.white), // Icon color set to white
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  sendMessage(String text) async {
    if (text.isEmpty) {
      print('Message is empty');
    } else {
      setState(() {
        addMessage(Message(text: DialogText(text: [text])), true);
      });

      DetectIntentResponse response = await dialogFlowtter.detectIntent(
          queryInput: QueryInput(text: TextInput(text: text)));

      if (response.message == null) return;

      String? eventName = extractEventName(text);

      if (eventName != null) {
        DocumentSnapshot eventDoc = await _firestore.collection('events').doc(eventName).get();

        if (eventDoc.exists) {
          Map<String, dynamic> eventData = eventDoc.data() as Map<String, dynamic>;
          String eventDetails = formatEventDetails(eventData);

          setState(() {
            addMessage(Message(text: DialogText(text: [eventDetails])), false); // Bot message in white
          });
        } else {
          setState(() {
            addMessage(Message(text: DialogText(text: ["Sorry, I couldn't find any event with that name."])), false);
          });
        }
      } else {
        setState(() {
          addMessage(response.message!, false); // Bot message in white
        });
      }
    }
  }

  // Function to extract the event name from the user's text input
  String? extractEventName(String text) {
    // Check if the text contains any of the event names fetched from Firestore
    for (String eventName in eventNames) {
      if (text.toLowerCase().contains(eventName.toLowerCase())) {
        return eventName;
      }
    }
    return null; // No matching event name found
  }

  String formatEventDetails(Map<String, dynamic> eventData) {
    return """
    Event Name: ${eventData['eventName']}
    Event Date: ${eventData['eventDate']}
    Location: ${eventData['eventLocation']}
    Price: ${eventData['eventPrice']}
    Type: ${eventData['eventType']}
    Deadline: ${eventData['deadline']}
    """;
  }

  addMessage(Message message, [bool isUserMessage = false]) {
    messages.add({
      'message': message,
      'isUserMessage': isUserMessage,
      'textStyle': TextStyle(color: Colors.white) // Ensures both user and bot messages are white
    });
  }
}
