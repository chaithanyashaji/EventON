import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gap/gap.dart';
import 'package:universe2024/Utiles/app_styles.dart'; // Ensure this import is correct
import 'package:universe2024/pages/loginpage.dart'; // Ensure this import is correct

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Stream<DocumentSnapshot>? _stream;

  @override
  void initState() {
    super.initState();
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserUid != null) {
      _stream = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserUid)
          .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _stream == null
          ? Center(child: Text('No user data found.'))
          : StreamBuilder<DocumentSnapshot>(
        stream: _stream,
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('No user data found.'));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final name = userData['name'] ?? '';
          final email = userData['email'] ?? '';
          final phoneNumber = userData['phoneNumber'] ?? '';
          final collegeName = userData['collegeName'] ?? '';
          final communityMember = userData['communityMember'] ?? '';
          final ieeeMembershipId = userData['ieeeMembershipId'] ?? '';

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Gap(20),
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Styles.blueColor.withOpacity(0.2),
                    child: Icon(
                      Icons.person,
                      size: 70,
                      color: Styles.blueColor,
                    ),
                  ),
                  const Gap(10),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 24,
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
                          const Gap(3),
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
                      const SizedBox(height: 10),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24.0),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Styles.yellowColor),
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Name  :  $name',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Styles.blueColor),
                              ),
                              const Gap(5),
                              Text(
                                'Email  :  $email',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Styles.blueColor),
                              ),
                              const Gap(5),
                              Text(
                                'Phone Number  : $phoneNumber',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Styles.blueColor),
                              ),
                              const Gap(5),
                              Text(
                                'College Name  :  $collegeName',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Styles.blueColor),
                              ),
                              const Gap(5),
                              Text(
                                'Community Name  :  $communityMember',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Styles.blueColor),
                              ),
                              const Gap(5),
                              Text(
                                'Membership ID  :  $ieeeMembershipId',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Styles.blueColor),
                              ),
                              Gap(5),
                              Center(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditDetailsForm(userData: userData),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Styles.blueColor,
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(17),
                                    ),
                                  ),
                                  icon: Icon(Icons.edit, color: Colors.white),
                                  label: Text('Edit Details', style: TextStyle(color: Colors.white)),
                                ),
                              ),

                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(100), // Gap between buttons
                  SizedBox(
                    width: 150,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const loginpage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Styles.blueColor,
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const Gap(30),
                ],
              ),
            ),
          );
        },
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
  late String _mobileNumber;
  late String _collegeName;
  late String _communityMember;
  late String _ieeeMembershipId;

  @override
  void initState() {
    super.initState();
    _name = widget.userData['name'] ?? '';
    _email = widget.userData['email'] ?? '';
    _mobileNumber = widget.userData['mobileNumber'] ?? '';
    _collegeName = widget.userData['collegeName'] ?? '';
    _communityMember = widget.userData['communityMember'] ?? '';
    _ieeeMembershipId = widget.userData['ieeeMembershipId'] ?? '';
  }

  void _saveDetails() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserUid != null) {
        await FirebaseFirestore.instance.collection('users').doc(currentUserUid).update({
          'name': _name,
          'mobileNumber': _mobileNumber,
          'collegeName': _collegeName,
          'communityMember': _communityMember,
          'ieeeMembershipId': _ieeeMembershipId,
        });
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double fieldWidth = MediaQuery.of(context).size.width * 0.85;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
        title: const Text('Edit Details', style: TextStyle(color: Colors.white)),
        backgroundColor: Styles.blueColor,
      ),
      body: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Container(
                    width: fieldWidth,
                    child: _buildTextField('Name', initialValue: _name, onSaved: (value) => _name = value!),
                  ),
                  const Gap(20),
                  Container(
                    width: fieldWidth,
                    child: _buildTextField('Mobile Number', initialValue: _mobileNumber, onSaved: (value) => _mobileNumber = value!),
                  ),
                  const Gap(20),
                  Container(
                    width: fieldWidth,
                    child: _buildTextField('College Name', initialValue: _collegeName, onSaved: (value) => _collegeName = value!),
                  ),
                  const Gap(20),
                  Container(
                    width: fieldWidth,
                    child: _buildTextField('Community Member', initialValue: _communityMember, onSaved: (value) => _communityMember = value!),
                  ),
                  const Gap(20),
                  Container(
                    width: fieldWidth,
                    child: _buildTextField('IEEE Membership ID', initialValue: _ieeeMembershipId, onSaved: (value) => _ieeeMembershipId = value!),
                  ),
                  const Gap(20),
                  Container(
                    width: fieldWidth,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saveDetails,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Styles.blueColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, {required String initialValue, required void Function(String?) onSaved}) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your $label';
        }
        return null;
      },
      onSaved: onSaved,
    );
  }
}

