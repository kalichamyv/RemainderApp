import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../service/firestore_service.dart';
import '../model/remainder.dart';
import '../service/notification_service.dart';

class CreateTask extends StatefulWidget {
  final ReminderModel? existingReminder;

  const CreateTask({super.key, this.existingReminder});

  @override
  State<CreateTask> createState() => _CreateTaskState();
}

class _CreateTaskState extends State<CreateTask> {
  final _formKey = GlobalKey<FormState>();

  final tasknameController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();
  final descriptionController = TextEditingController();
  final phoneController = TextEditingController();

  final FirestoreService firestoreService = FirestoreService();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  DateTime? combinedDateTime;

  File? selectedFile;
  String? selectedRepeat;
  String? selectNotification;

  final List<String> repeatOptions = [
    'Today once',
    'Weekly once',
    'Monthly once',
  ];

  final List<String> notificationOptions = [
    'No Duration',
    '15 Mins',
    '30 Mins',
    '45 Mins',
    '1 Hour',
  ];

  @override
  void initState() {
    super.initState();

    if (widget.existingReminder != null) {
      final r = widget.existingReminder!;
      tasknameController.text = r.taskname;
      descriptionController.text = r.description;
      phoneController.text = r.phoneNumber;
      selectedRepeat = r.repeat;
      selectNotification = r.notification;

      selectedDate = r.date;
      selectedTime = TimeOfDay(hour: r.date.hour, minute: r.date.minute);

      dateController.text = '${r.date.day}/${r.date.month}/${r.date.year}';
      timeController.text =
          '${r.date.hour}:${r.date.minute.toString().padLeft(2, '0')}';

      if (r.filePath != null) {
        selectedFile = File(r.filePath!);
      }
    }
  }

  void combineDateTime() {
    if (selectedDate != null && selectedTime != null) {
      combinedDateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        selectedFile = File(image.path);
      });
    }
  }

  @override
  void dispose() {
    tasknameController.dispose();
    dateController.dispose();
    timeController.dispose();
    descriptionController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingReminder == null ? 'Create Reminder' : 'Edit Reminder',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                /// Task Name
                TextFormField(
                  controller: tasknameController,
                  decoration: _inputDecoration('Task Name', Icons.task),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Name is required'
                      : null,
                ),
                const SizedBox(height: 12),

                /// Date & Time
                /// DATE
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: dateController,
                        readOnly: true,
                        decoration: _inputDecoration(
                          'Date',
                          Icons.calendar_month,
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Date is required'
                            : null,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );

                          if (picked != null) {
                            setState(() {
                              selectedDate = picked;

                              dateController.text = DateFormat(
                                'dd/MM/yyyy',
                              ).format(picked);

                              /// Reset time when date changes
                              selectedTime = null;
                              timeController.clear();
                            });
                          }
                        },
                      ),
                    ),

                    const SizedBox(width: 10),

                    /// Time
                    Expanded(
                      child: TextFormField(
                        controller: timeController,
                        readOnly: true,
                        decoration: _inputDecoration('Time', Icons.timelapse),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Time is required'
                            : null,
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: selectedTime ?? TimeOfDay.now(),
                          );

                          if (picked != null) {
                            setState(() {
                              selectedTime = picked;
                              timeController.text = picked.format(context);
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                /// Description
                TextFormField(
                  controller: descriptionController,
                  maxLines: 4,
                  decoration: _inputDecoration(
                    'Description',
                    Icons.description,
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Description is required'
                      : null,
                ),

                const SizedBox(height: 12),

                /// Phone
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: _inputDecoration('Phone', Icons.phone),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter phone number';
                    }
                    if (value.length != 10) {
                      return 'Enter valid 10 digit number';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                /// Notification Dropdown
                DropdownButtonFormField<String>(
                  value: selectNotification,
                  decoration: _inputDecoration(
                    'Notification',
                    Icons.notifications,
                  ),
                  items: notificationOptions
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectNotification = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Select notification' : null,
                ),

                const SizedBox(height: 12),

                /// Repeat Dropdown
                DropdownButtonFormField<String>(
                  value: selectedRepeat,
                  decoration: _inputDecoration('Repeat', Icons.repeat),
                  items: repeatOptions
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedRepeat = value;
                    });
                  },
                  validator: (value) => value == null ? 'Select repeat' : null,
                ),

                const SizedBox(height: 12),

                /// Image Upload
                InkWell(
                  onTap: pickImage,
                  child: Container(
                    height: 55,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        SizedBox(width: 15),
                        Icon(Icons.upload),
                        SizedBox(width: 10),
                        Text('Upload file or photo'),
                      ],
                    ),
                  ),
                ),

                if (selectedFile != null) ...[
                  const SizedBox(height: 10),
                  Image.file(selectedFile!, height: 120),
                ],

                const SizedBox(height: 20),

                /// Save Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        combineDateTime();

                        if (combinedDateTime == null) return;

                        /// Notification Duration
                        Duration reminderDuration = Duration.zero;

                        if (selectNotification == "15 Mins") {
                          reminderDuration = const Duration(minutes: 15);
                        } else if (selectNotification == "30 Mins") {
                          reminderDuration = const Duration(minutes: 30);
                        } else if (selectNotification == "45 Mins") {
                          reminderDuration = const Duration(minutes: 45);
                        } else if (selectNotification == "1 Hour") {
                          reminderDuration = const Duration(hours: 1);
                        } else if (selectNotification == "No Duration") {
                          reminderDuration = Duration.zero;
                        }

                        /// Notification Time
                        DateTime notificationTime = combinedDateTime!.subtract(
                          reminderDuration,
                        );

                        DateTime now = DateTime.now();

                        /// Prevent past notifications
                        if (selectNotification != "No Duration" &&
                            notificationTime.isBefore(now)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Reminder time already passed. Please select another time.",
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );

                          return;
                        }

                        // /// Debug
                        // print("Current Time: $now");
                        // print("Task Time: $combinedDateTime");
                        // print("Notification Time: $notificationTime");
                        // print("Repeat Type: $selectedRepeat");

                        /// Notification ID
                        final notificationId =
                            widget.existingReminder?.notificationId ??
                            DateTime.now().millisecondsSinceEpoch.remainder(
                              100000,
                            );

                        /// Reminder Model
                        final reminder = ReminderModel(
                          userid: user.uid,
                          taskname: tasknameController.text,
                          description: descriptionController.text,
                          phoneNumber: phoneController.text,
                          date: combinedDateTime!,
                          time: combinedDateTime!,
                          repeat: selectedRepeat!,
                          notification: selectNotification!,
                          filePath: selectedFile?.path,
                          docId: widget.existingReminder?.docId,
                          notificationId: notificationId,
                        );

                        /// UPDATE REMINDER
                        if (widget.existingReminder != null) {
                          /// Cancel old notification
                          await NotificationService.cancel(notificationId);

                          await firestoreService.updateReminder(reminder);
                        } else {
                          /// Create new reminder
                          await firestoreService.createRemainder(
                            uid: user.uid,
                            reminder: reminder,
                          );
                        }

                        /// Schedule Notification
                        if (selectNotification != "No Duration" ||
                            selectNotification == "No Duration") {
                          if (reminder.repeat == "Today once") {
                            await NotificationService.scheduleOnce(
                              id: notificationId,
                              title: reminder.taskname,
                              body: reminder.description,
                              dateTime: notificationTime,
                            );
                          } else if (reminder.repeat == "Weekly once") {
                            await NotificationService.scheduleWeekly(
                              id: notificationId,
                              title: reminder.taskname,
                              body: reminder.description,
                              dateTime: notificationTime,
                            );
                          } else if (reminder.repeat == "Monthly once") {
                            await NotificationService.scheduleMonthly(
                              id: notificationId,
                              title: reminder.taskname,
                              body: reminder.description,
                              dateTime: notificationTime,
                            );
                          }
                        }
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Save'),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration(String hint, IconData icon) {
  return InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.white,
    prefixIcon: Icon(icon),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
  );
}
