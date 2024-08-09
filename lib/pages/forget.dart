import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _emailSent = false;
  bool _error = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendPasswordResetEmail() async {
    final email = _emailController.text;

    if (email.isEmpty) {
      setState(() {
        _error = true;
        _errorMessage = 'Please enter an email address.';
      });
      return;
    }

    try {
      // Attempt to send the password reset email
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      // Success
      setState(() {
        _emailSent = true;
        _error = false;
        _errorMessage = '';
      });
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Auth errors
      if (e.code == 'user-not-found') {
        // Email does not exist
        setState(() {
          _error = true;
          _errorMessage = 'No account found with this email address.';
        });
      } else if (e.code == 'invalid-email') {
        // Invalid email format
        setState(() {
          _error = true;
          _errorMessage = 'Invalid email address format.';
        });
      } else {
        // Other errors
        setState(() {
          _error = true;
          _errorMessage = 'Error sending email. Please try again.';
        });
      }
      print("Error sending password reset email: $e");
    } catch (e) {
      // General errors
      setState(() {
        _error = true;
        _emailSent = false;
        _errorMessage = 'Error sending email. Please try again.';
      });
      print("Error sending password reset email: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Forgot Password')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_emailSent)
              Text(
                'Password reset email sent. Please check your inbox.',
                style: TextStyle(color: Colors.green),
              ),
            if (_error)
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
              ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Enter your email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendPasswordResetEmail,
              child: Text('Send Reset Email'),
            ),
          ],
        ),
      ),
    );
  }
}
