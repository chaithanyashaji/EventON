import 'package:flutter/material.dart';
import 'package:universe2024/pages/Eventdetails.dart';

class MyEventsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Replace this with your data source for My Events
    List<Map> myEvents = [
      {
        'eventName': 'Event 1',
        'eventDate': '2024-08-10',
        'eventLocation': 'Location 1',
        'eventPrice': '\$20',
        'eventtype': 'Type 1',
        'documentID': '1',
      },
      // Add more events as needed
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('My Events'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView.builder(
          itemCount: myEvents.length,
          itemBuilder: (context, index) {
            Map event = myEvents[index];
            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event['eventName'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text('Date: ${event['eventDate']}'),
                    Text('Location: ${event['eventLocation']}'),
                    Text('Price: ${event['eventPrice']}'),
                    Text('Type: ${event['eventtype']}'),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EventDetails(eventKey: event['documentID']),
                          ),
                        );
                      },
                      child: Text('View Details'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
