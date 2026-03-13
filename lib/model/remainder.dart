import 'package:cloud_firestore/cloud_firestore.dart';

class ReminderModel {
  String? docId;
  String userid;
  String taskname;
  String description;
  String phoneNumber;

  DateTime date;
  DateTime time;

  String notification;
  String repeat;
  bool? isCompleted;

  String? filePath;
  int notificationId;

  ReminderModel({
    this.docId,
    required this.userid,
    required this.taskname,
    required this.description,
    required this.phoneNumber,
    required this.date,
    required this.time,
    required this.notification,
    required this.repeat,
    this.isCompleted,
    this.filePath,
    required this.notificationId,
  });

  /// Firestore - Model
  factory ReminderModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ReminderModel(
      docId: doc.id,
      userid: data['userid'] ?? '',
      taskname: data['taskname'] ?? '',
      description: data['description'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      time: (data['time'] as Timestamp).toDate(),
      notification: data['notification'] ?? '',
      repeat: data['repeat'] ?? '',
      isCompleted: data['isCompleted'],
      filePath: data['filePath'],
      notificationId: data['notificationId'] ?? 0,
    );
  }

  /// Model - Firestore
  Map<String, dynamic> toMap() {
    return {
      'userid': userid,
      'taskname': taskname,
      'description': description,
      'phoneNumber': phoneNumber,
      'date': date,
      'time': time,
      'notification': notification,
      'repeat': repeat,
      'isCompleted': isCompleted,
      'filePath': filePath,
      'notificationId': notificationId,
    };
  }
}
