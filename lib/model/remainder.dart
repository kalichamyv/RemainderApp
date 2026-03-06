import 'package:cloud_firestore/cloud_firestore.dart';

class ReminderModel {
  final String userid;
  final String taskname;
  final String description;
  final String phoneNumber;
  final DateTime date; // combined date and time
  final DateTime time; // same as date for convenience
  final String repeat; // Today once / Weekly once / Monthly once
  final String notification; // Notification duration: 15 Mins, 30 Mins, etc.
  final String? filePath;
  final String? docId; // Firestore document ID
  bool? isCompleted; // null = pending, true = completed, false = incomplete

  ReminderModel({
    required this.userid,
    required this.taskname,
    required this.description,
    required this.phoneNumber,
    required this.date,
    required this.time,
    required this.repeat,
    required this.notification,
    this.filePath,
    this.docId,
    this.isCompleted, // default null = pending
  });

  /// Convert model to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'userid': userid,
      'taskname': taskname,
      'description': description,
      'phoneNumber': phoneNumber,
      'date': Timestamp.fromDate(date), // combined datetime
      'time': Timestamp.fromDate(time), // same as date
      'repeat': repeat,
      'notification': notification,
      'filePath': filePath,
      'createdAt': Timestamp.now(),
      'isCompleted': isCompleted, // null/pending, true/completed, false/incomplete
    };
  }

  /// Convert Firestore document to ReminderModel
  factory ReminderModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReminderModel(
      userid: data['userid'],
      taskname: data['taskname'],
      description: data['description'],
      phoneNumber: data['phoneNumber'],
      date: (data['date'] as Timestamp).toDate(),
      time: (data['time'] as Timestamp).toDate(),
      repeat: data['repeat'],
      notification: data['notification'],
      filePath: data['filePath'],
      docId: doc.id,
      isCompleted: data.containsKey('isCompleted') ? data['isCompleted'] as bool? : null,
    );
  }
}