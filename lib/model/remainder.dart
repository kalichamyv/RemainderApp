import 'package:cloud_firestore/cloud_firestore.dart';

class ReminderModel {
  final String userid;
  final String taskname;
  final String description;
  final String phoneNumber;
  final DateTime date;
  final String repeat;
  final String? filePath;
  final String? docId; // Firestore document ID

  ReminderModel({
    required this.userid,
    required this.taskname,
    required this.description,
    required this.phoneNumber,
    required this.date,
    required this.repeat,
    this.filePath,
    this.docId,
  });

  // Convert model → Firestore
  Map<String, dynamic> toMap() {
    return {
      'userid': userid,
      'taskname': taskname,
      'description': description,
      'phoneNumber': phoneNumber,
      'date': Timestamp.fromDate(date),
      'repeat': repeat,
      'filePath': filePath,
      'createdAt': Timestamp.now(),
    };
  }

  // Convert Firestore doc → model
  factory ReminderModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReminderModel(
      userid: data['userid'],
      taskname: data['taskname'],
      description: data['description'],
      phoneNumber: data['phoneNumber'],
      date: (data['date'] as Timestamp).toDate(),
      repeat: data['repeat'],
      filePath: data['filePath'],
      docId: doc.id,
    );
  }
}