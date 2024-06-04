import 'package:firebase_auth/firebase_auth.dart';

//fx to get currect userID
final FirebaseAuth auth = FirebaseAuth.instance;
String getUID() {
  final User user = auth.currentUser!;
  final uid = user.uid;
  print("UID = "+uid);
  return uid;
}