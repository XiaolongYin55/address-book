import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/contact.dart';
import '../services/db_helper.dart';

class ContactInsertPage extends StatefulWidget {
  const ContactInsertPage({super.key});

  @override
  State<ContactInsertPage> createState() => _ContactInsertPageState();
}

class _ContactInsertPageState extends State<ContactInsertPage> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final avatarController = TextEditingController();

  File? avatarPreview;

  Future<void> selectAvatar() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName =
          DateTime.now().microsecondsSinceEpoch.toString() + '.jpg';
      final savedImage =
          await File(pickedFile.path).copy('${appDir.path}/$fileName');

      avatarController.text = savedImage.path;
      print('Saved avatar path: ${savedImage.path}');
      print('File exists: ${await savedImage.exists()}');
      setState(() {
        avatarPreview = savedImage;
      });
    } catch (e) {
      print('Error saving image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Insert Contact')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                    avatarPreview != null ? FileImage(avatarPreview!) : null,
                child: avatarPreview == null
                    ? const Icon(Icons.person, size: 40)
                    : null,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: selectAvatar,
              child: const Text('Select Avatar'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone (+60)',
                hintText: 'e.g. 1127309358',
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
            ),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'e.g. paul@google.com',
              ),
            ),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                //* ------------------ Validate email & phone format ------------------------
                final rawPhone = phoneController.text.trim();
                final formattedPhone = '+60 ${rawPhone}';
                final email = emailController.text.trim();
                final phoneRegex = RegExp(r'^\d{9,10}$');
                final emailRegex = RegExp(r'^\S+@\S+\.\S+$');

                if (!phoneRegex.hasMatch(rawPhone)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Invalid phone number format.')),
                  );
                  return;
                }

                if (!emailRegex.hasMatch(email)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid email format.')),
                  );
                  return;
                }

                final contact = Contact(
                  name: nameController.text.trim(),
                  phone: formattedPhone,
                  email: email,
                  address: addressController.text.trim(),
                  avatar: avatarController.text,
                );

                await DBHelper().insertContact(contact);
                Navigator.pop(context, true);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}




