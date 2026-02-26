import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/remainder.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Save reminder for a user
  Future<void> createRemainder({
    required String uid,
    required ReminderModel reminder,
  }) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('reminders')
        .add(reminder.toMap());
  }

  // Fetch reminders for a user
  Stream<List<ReminderModel>> getReminders(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('reminders')
        .orderBy('date')
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => ReminderModel.fromSnapshot(doc)).toList());
  }

  // Delete reminder
  Future<void> deleteReminder(String uid, String docId) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('reminders')
        .doc(docId)
        .delete();
  }
}