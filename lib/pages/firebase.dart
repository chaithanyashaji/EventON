import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  Future<User?> LoginWithEmailAndPassword(String email,String password) async{
    try{
      final credential= await _auth.signInWithEmailAndPassword(email: email, password: password);
      return credential.user;

    }catch (e) {
      print("Some error occured");
    }
    return null;
  }
  FirebaseAuth _auth = FirebaseAuth.instance;
  Future<User?> signUpWithEmailAndPassword(String email,String password) async{
    try{
      final credential= await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return credential.user;

    }catch (e) {
      print("Some error occured");
    }
    return null;
  }



}