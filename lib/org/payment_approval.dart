import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class PayApprovalsPage extends StatefulWidget {
  final String userId;

  PayApprovalsPage({required this.userId});

  @override
  _PayApprovalsPageState createState() => _PayApprovalsPageState();
}

class _PayApprovalsPageState extends State<PayApprovalsPage> {
  late Stream<List<Map<String, dynamic>>> _paymentsStream;
  late Stream<int> _pendingCountStream;

  @override
  void initState() {
    super.initState();
    _setupPaymentsStream();
    _setupPendingCountStream();
  }

  void _setupPaymentsStream() {
    Stream<List<String>> eventIdsStream = FirebaseFirestore.instance
        .collection('EVENTS')
        .where('addedBy', isEqualTo: widget.userId)
        .snapshots()
        .map((eventsSnapshot) {
      return eventsSnapshot.docs.map((eventDoc) => eventDoc.id).toList();
    });

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
            'collegeName': doc['_collegeName'],
            'semester': doc['_semester'],
            'branch': doc['_branch'],
            'userName': doc['userName'],
            'mobileNumber': doc['_mobileNumber'], // Add phoneNumber field
            'PaymentScreenshot': doc['PaymentScreenshot'],
          };
        }).toList();
      });
    });
  }

  void _setupPendingCountStream() {
    Stream<List<String>> eventIdsStream = FirebaseFirestore.instance
        .collection('EVENTS')
        .where('addedBy', isEqualTo: widget.userId)
        .snapshots()
        .map((eventsSnapshot) {
      return eventsSnapshot.docs.map((eventDoc) => eventDoc.id).toList();
    });

    _pendingCountStream = eventIdsStream.switchMap((eventIds) {
      if (eventIds.isEmpty) {
        return Stream.value(0);
      }

      return FirebaseFirestore.instance
          .collection('REGISTRATIONS')
          .where('eventId', whereIn: eventIds)
          .where('PaymentStatus', isEqualTo: 'pending')
          .snapshots()
          .map((registrationsSnapshot) {
        return registrationsSnapshot.docs.length;
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

  void _showImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black,
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 300,
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black, backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Payment Approvals')),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder<int>(
              stream: _pendingCountStream,
              builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                return Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'Pending Approvals: ${snapshot.data ?? 0}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
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
                    itemCount: payments.length,
                    itemBuilder: (context, index) {
                      var payment = payments[index];
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: Card(
                          color: Colors.black,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.all(12),
                                title: Text(
                                  payment['eventName'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.school, color: Colors.white70, size: 20),
                                        SizedBox(width: 8),
                                        Text(
                                          'College: ${payment['collegeName']}',
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.business, color: Colors.white70, size: 20),
                                        SizedBox(width: 8),
                                        Text(
                                          'Branch: ${payment['branch']}',
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.book, color: Colors.white70, size: 20),
                                        SizedBox(width: 8),
                                        Text(
                                          'Semester: ${payment['semester']}',
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.person, color: Colors.white70, size: 20),
                                        SizedBox(width: 8),
                                        Text(
                                          'Name: ${payment['userName']}',
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.phone, color: Colors.white70, size: 20),
                                        SizedBox(width: 8),
                                        Text(
                                          'Phone: ${payment['mobileNumber']}',
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    payment['PaymentScreenshot'] != null
                                        ? GestureDetector(
                                      onTap: () => _showImage(payment['PaymentScreenshot']),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          payment['PaymentScreenshot'],
                                          height: 150,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    )
                                        : Text(
                                      'No screenshot available',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    _approvePayment(payment['id']);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white, backgroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  icon: Icon(Icons.check, color: Colors.white),
                                  label: Text('Approve'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
