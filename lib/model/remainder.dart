class ReminderModel {
  final String taskname;
  final String description;
  final String phoneNumber;
  final DateTime date;
  final String repeat;
  final String? filePath;

  ReminderModel({
    required this.taskname,
    required this.description,
    required this.phoneNumber,
    required this.date,
    required this.repeat,
    this.filePath
  });
  Map<String, dynamic> toMap() {
    return {
      'taskname': taskname,
      'description': description,
      'phoneNumber': phoneNumber,
      'date': date.toIso8601String(),
      'repeat': repeat,
      'filePath': filePath,
    };
  }
  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
      taskname: map['taskname'],
      description: map['description'],
      phoneNumber: map['phoneNumber'],
      date: DateTime.parse(map['date']),
      repeat: map['repeat'],
      filePath: map['filePath'],
    );
  }
}

