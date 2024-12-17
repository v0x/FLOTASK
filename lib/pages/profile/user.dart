import 'package:firebase_auth/firebase_auth.dart';

class FTUser{
  String username;
  String email;
  String password;
  String id; 

  FTUser({
    this.username = "default",
    this.email = "default@default.com",
    this.password = "default",
    this.id = "default",
  });

  static FTUser FTUserFromFirebase(User firebaseuser) {
    return FTUser(id: firebaseuser.uid, email: firebaseuser.email!);
  }
}
