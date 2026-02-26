import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../service/firestore_service.dart';
import '../model/remainder.dart';

class CreateTask extends StatefulWidget {
  const CreateTask({super.key});

  @override
  State<CreateTask> createState() => _CreateTaskState();
}

class _CreateTaskState extends State<CreateTask> {
  final _formKey = GlobalKey<FormState>();

  final tasknameController = TextEditingController();
  final dateController = TextEditingController();
  final descriptionController = TextEditingController();
  final phoneController = TextEditingController();

  final FirestoreService firestoreService = FirestoreService();

  DateTime? selectedDate;
  File? selectedFile;
  String? selectedRepeat;

  final List<String> repeatOptions = [
    'Today once',
    'Weekly once',
    'Monthly once',
  ];

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
    descriptionController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      appBar: AppBar(title: const Text('Create Reminder')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: tasknameController,
                  decoration: _inputDecoration('TaskName', Icons.task),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: dateController,
                  readOnly: true,
                  decoration: _inputDecoration('Date', Icons.calendar_today),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Date is required' : null,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                        dateController.text =
                        '${picked.day}/${picked.month}/${picked.year}';
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descriptionController,
                  maxLines: 5,
                  decoration: _inputDecoration('Description', Icons.description),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Description is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: _inputDecoration('Phone Number', Icons.phone),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Enter the phone number';
                    if (value.length != 10) return 'Enter a valid 10-digit number';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedRepeat,
                  decoration: _inputDecoration('Repeat', Icons.arrow_drop_down),
                  items: repeatOptions
                      .map((option) => DropdownMenuItem(
                    value: option,
                    child: Text(option),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedRepeat = value;
                    });
                  },
                  validator: (value) =>
                  value == null ? 'Please select repeat option' : null,
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: pickImage,
                  child: Container(
                    height: 55,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 15),
                        const Icon(Icons.upload),
                        const SizedBox(width: 10),
                        Text(
                          selectedFile == null
                              ? 'Upload file or photo'
                              : 'File selected',
                        ),
                      ],
                    ),
                  ),
                ),
                if (selectedFile != null) ...[
                  const SizedBox(height: 10),
                  Image.file(selectedFile!, height: 120),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final reminder = ReminderModel(
                          userid: user.uid,
                          taskname: tasknameController.text,
                          description: descriptionController.text,
                          phoneNumber: phoneController.text,
                          date: selectedDate!,
                          repeat: selectedRepeat!,
                          filePath: selectedFile?.path,
                        );
                        await firestoreService.createRemainder(
                          uid: user.uid,
                          reminder: reminder,
                        );
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Create', style: TextStyle(fontSize: 16)),
                  ),
                ),
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