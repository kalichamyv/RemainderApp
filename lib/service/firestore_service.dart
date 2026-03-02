import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/remainder.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createRemainder({
    required String uid,
    required ReminderModel reminder,
  }) async {
    await _db.collection('reminders').add({
      ...reminder.toMap(),
      'userid': uid,
    });
  }

  Stream<List<ReminderModel>> getReminders(String uid) {
    return _db
        .collection('reminders')
        .where('userid', isEqualTo: uid)
        .orderBy('date')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ReminderModel.fromSnapshot(doc))
        .toList());
  }

  Future<void> deleteReminder(String docId) async {
    await _db.collection('reminders').doc(docId).delete();
  }
}