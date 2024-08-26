import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';



class PayApprovalsPage extends StatefulWidget {
  final String userId;

  PayApprovalsPage({required this.userId});

  @override
  _ApprovalsPageState createState() => _ApprovalsPageState();
}

class _ApprovalsPageState extends State<PayApprovalsPage> {
  late Stream<List<Map<String, dynamic>>> _paymentsStream;

  @override
  void initState() {
    super.initState();
    _setupPaymentsStream();
  }

  void _setupPaymentsStream() {
    // Stream of events added by the current user
    Stream<List<String>> eventIdsStream = FirebaseFirestore.instance
        .collection('EVENTS')
        .where('addedby', isEqualTo: widget.userId)
        .snapshots()
        .map((eventsSnapshot) {
          return eventsSnapshot.docs.map((eventDoc) => eventDoc.id).toList();
        });

    // Stream of payments for these events
    _paymentsStream = eventIdsStream.switchMap((eventIds) {
      if (eventIds.isEmpty) {
        return Stream.value([]);
      }

      return FirebaseFirestore.instance
          .collection('REGISTRATIONS')
          .where('eventId', whereIn: eventIds)
          .where('PaymentStatus', isEqualTo: 'pending')
          .snapshots()
          .map((registrationsSnapshot) {
            return registrationsSnapshot.docs.map((doc) {
              return {
                'id': doc.id,
                'eventName': doc['eventName'],
                'userName': doc['userName'],
                'PaymentScreenshot': doc['PaymentScreenshot'],
                'registrationId': doc['registrationId'],
              };
            }).toList();
          });
    });
  }

  void _approvePayment(String registrationId) {
    FirebaseFirestore.instance.collection('REGISTRATIONS').doc(registrationId).update({
      'PaymentStatus': 'approved',
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment approved successfully')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to approve payment: $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Approvals'),
      ),
      body: ListView(
        children: [
          ExpansionTile(
            title: Text('Payment Approvals'),
            children: [
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: _paymentsStream,
                builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No pending payments'));
                  }

                  var payments = snapshot.data!;

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: payments.length,
                    itemBuilder: (context, index) {
                      var payment = payments[index];
                      return ListTile(
                        title: Text('Event Name: ${payment['eventName']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('User Name: ${payment['userName']}'),
                            SizedBox(height: 8),
                            payment['PaymentScreenshot'] != null
                                ? Image.network(payment['PaymentScreenshot'])
                                : Text('No screenshot available'),
                          ],
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            _approvePayment(payment['id']);
                          },
                          child: Text('Approve'),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
