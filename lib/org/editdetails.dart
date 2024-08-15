import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gap/gap.dart';
import 'package:universe2024/Utiles/app_styles.dart';

class EditDetailsForm extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const EditDetailsForm({required this.userData, Key? key}) : super(key: key);

  @override
  _EditDetailsFormState createState() => _EditDetailsFormState();
}

class _EditDetailsFormState extends State<EditDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  late String name;
  late String email;
  late String mobileNumber;
  late String collegeName;

  @override
  void initState() {
    super.initState();
    name = widget.userData?['name'] ?? '';
    email = widget.userData?['email'] ?? '';
    mobileNumber = widget.userData?['mobileNumber'] ?? '';
    collegeName = widget.userData?['collegeName'] ?? '';
  }

  Future<void> _updateUserData() async {
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserUid != null) {
      await FirebaseFirestore.instance.collection('users').doc(currentUserUid).update({
        'name': name,
        'email': email,
        'mobileNumber': mobileNumber,
        'collegeName': collegeName,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double fieldWidth = MediaQuery.of(context).size.width * 0.85;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text('Edit Details', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Name Field
                  Container(
                    width: fieldWidth,
                    child: _buildTextField('Name', initialValue: name, onSaved: (value) => name = value ?? ''),
                  ),
                  const Gap(20),

                  // Mobile Number Field
                  Container(
                    width: fieldWidth,
                    child: _buildTextField('Mobile Number', initialValue: mobileNumber, onSaved: (value) => mobileNumber = value ?? ''),
                  ),
                  const Gap(20),

                  // College Name Field
                  Container(
                    width: fieldWidth,
                    child: _buildTextField('College Name', initialValue: collegeName, onSaved: (value) => collegeName = value ?? ''),
                  ),
                  const Gap(20),

                  // Save Button
                  Container(
                    width: fieldWidth,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          _formKey.currentState?.save();
                          await _updateUserData();
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Styles.blueColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
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
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
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
