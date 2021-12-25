import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? equation;
  DatabaseService(this.equation);


  CollectionReference history =
      FirebaseFirestore.instance.collection('history');

  Future<void> addHistory() {
    // Call the user's CollectionReference to add a new user
    return history
        .add({"equation": equation})
        .then((value) => print("equation Added"))
        .catchError((error) => print("Failed to add equation: $error"));
  }
}
