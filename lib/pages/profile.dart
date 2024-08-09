import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gap/gap.dart';
import 'package:universe2024/Utiles/app_styles.dart';
import 'package:universe2024/pages/loginpage.dart'; // Ensure this is correctly imported

class Profile extends StatefulWidget {
  const Profile({Key? key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late Stream<DocumentSnapshot> _stream;

  @override
  void initState() {
    super.initState();
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
    _stream = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserUid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Styles.yellowColor,
                Styles.lblueColor,
                Styles.blueColor,
              ],
            ),
          ),
        ),
        title: Text(
          'Profile',
          style: TextStyle(
              color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
        ),
        leading: SizedBox(
          width: 800,
          height: double.infinity,
          child: Image.asset(
            'assets/logowhite.png',
            fit: BoxFit.fitHeight,
          ),
        ),
        backgroundColor: Styles.blueColor,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: StreamBuilder<DocumentSnapshot>(
          stream: _stream,
          builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            final userData = snapshot.data?.data() as Map<String, dynamic>;
            final name = userData['name'] ?? '';
            final email = userData['email'] ?? '';
            final phoneNumber = userData['phoneNumber'] ?? '';
            final collegeName = userData['collegeName'] ?? '';
            final communityMember = userData['communityMember'] ?? '';
            final MembershipId = userData['MembershipId'] ?? '';

            return SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const Gap(20),
                            Icon(
                              Icons.person,
                              size: 90,
                              color: Styles.blueColor,
                            ),
                            const Gap(10),
                            Text(
                              "$name",
                              style: TextStyle(
                                fontSize: 22,
                                color: Styles.blueColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Gap(50),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(left: 27.0),
                                      child: Icon(
                                        Icons.note_alt_outlined,
                                        color: Styles.blueColor,
                                      ),
                                    ),
                                    Gap(3),
                                    Text(
                                      'About me',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Styles.blueColor,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Container(
                                  margin: const EdgeInsets.only(left: 24.0, right: 24),
                                  width: 450,
                                  height: 210,
                                  decoration: BoxDecoration(
                                    border: Border.all(width: 1, color: Styles.yellowColor),
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Name  :  $name',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Styles.blueColor),
                                                ),
                                                Gap(5),
                                                Text(
                                                  'Email  :  $email',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Styles.blueColor),
                                                ),
                                                Gap(5),
                                                Text(
                                                  'Phone Number  : $phoneNumber',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Styles.blueColor),
                                                ),
                                                Gap(5),
                                                Text(
                                                  'College Name  :  $collegeName',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Styles.blueColor),
                                                ),
                                                Gap(5),
                                                Text(
                                                  'Community Member  :  $communityMember',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Styles.blueColor),
                                                ),
                                                Gap(5),
                                                Text(
                                                  'Membership ID  :  $MembershipId',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Styles.blueColor),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const Gap(12),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              alignment: Alignment.center,
                                              child: TextButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => EditDetailsForm(userData: userData),
                                                    ),
                                                  );
                                                },
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.add, color: Styles.blueColor),
                                                    Text(
                                                      'Edit Details',
                                                      style: TextStyle(
                                                          color: Styles.blueColor,
                                                          fontWeight: FontWeight.w600),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Gap(50),
                            Gap(30),
                            Container(
                              width: 150,
                              height: 40,
                              child: Material(
                                elevation: 8,
                                borderRadius: BorderRadius.circular(25),
                                child: SizedBox(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => loginpage()),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Styles.blueColor,
                                    ),
                                    child: Text(
                                      'Logout',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Gap(30),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class EditDetailsForm extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditDetailsForm({Key? key, required this.userData}) : super(key: key);

  @override
  _EditDetailsFormState createState() => _EditDetailsFormState();
}

class _EditDetailsFormState extends State<EditDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _email;
  late String _phoneNumber;
  late String _collegeName;
  late String _communityMember; // Add this line
  late String _MembershipId; // Add this line

  @override
  void initState() {
    super.initState();
    _name = widget.userData['name'] ?? '';
    _email = widget.userData['email'] ?? '';
    _phoneNumber = widget.userData['phoneNumber'] ?? '';
    _collegeName = widget.userData['collegeName'] ?? '';
    _communityMember = widget.userData['communityMember'] ?? ''; // Initialize
    _MembershipId = widget.userData['MembershipId'] ?? ''; // Initialize
  }

  void _saveDetails() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
      FirebaseFirestore.instance.collection('users').doc(currentUserUid).update({
        'name': _name,
        'phoneNumber': _phoneNumber,
        'collegeName': _collegeName,
        'communityMember': _communityMember, // Save this field
        'MembershipId': _MembershipId, // Save this field
      }).then((value) {
        Navigator.pop(context);
      }).catchError((error) {
        print('Error updating user details: $error');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Details'),
        backgroundColor: Styles.blueColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Existing form fields
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value!;
                },
              ),
              TextFormField(
                initialValue: _email,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.grey),
                ),
                enabled: false,
              ),
              TextFormField(
                initialValue: _phoneNumber,
                decoration: InputDecoration(labelText: 'Phone Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
                onSaved: (value) {
                  _phoneNumber = value!;
                },
              ),
              TextFormField(
                initialValue: _collegeName,
                decoration: InputDecoration(labelText: 'College Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your college name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _collegeName = value!;
                },
              ),
              // New form fields
              TextFormField(
                initialValue: _communityMember,
                decoration: InputDecoration(labelText: 'Community Member (Optional)'),
                onSaved: (value) {
                  _communityMember = value!;
                },
              ),
              TextFormField(
                initialValue: _MembershipId,
                decoration: InputDecoration(labelText: 'Membership ID (Optional)'),
                onSaved: (value) {
                  _MembershipId = value!;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveDetails,
                style: ElevatedButton.styleFrom(backgroundColor: Styles.blueColor),
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
