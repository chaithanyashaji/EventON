import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ApprovalsPage extends StatefulWidget {
  @override
  _ApprovalsPageState createState() => _ApprovalsPageState();
}

class _ApprovalsPageState extends State<ApprovalsPage> {
  late Stream<List<Map<String, dynamic>>> _usersStream;

  @override
  void initState() {
    super.initState();
    _setupUsersStream();
  }

  void _setupUsersStream() {
    _usersStream = FirebaseFirestore.instance
        .collection('users')
        .where('status', isEqualTo: 'pending') // Assuming users have a 'status' field
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return {
              'id': doc.id,
              'name': doc['name'], // Assuming user documents have 'name' field
              'email': doc['email'], // Assuming user documents have 'email' field
            };
          }).toList();
        });
  }

  void _approveUser(String userId) {
    FirebaseFirestore.instance.collection('users').doc(userId).update({
      'status': 'approved',
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User approved successfully')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to approve user: $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Approvals'),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _usersStream,
        builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No users pending approval'));
          }

          var users = snapshot.data!;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              var user = users[index];
              return ListTile(
                title: Text(user['name']),
                subtitle: Text(user['email']),
                trailing: ElevatedButton(
                  onPressed: () {
                    _approveUser(user['id']);
                  },
                  child: Text('Approve'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
