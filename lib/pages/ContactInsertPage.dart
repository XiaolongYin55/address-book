import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/contact.dart';
import '../services/db_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/services.dart';

class ContactInsertPage extends StatefulWidget {
  const ContactInsertPage({super.key});

  @override
  State<ContactInsertPage> createState() => _ContactInsertPageState();
}

class _ContactInsertPageState extends State<ContactInsertPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  File? _avatarImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final imgDir = Directory(p.join(appDir.path, 'img'));

      if (!await imgDir.exists()) {
        await imgDir.create(recursive: true);
      }

      final String newPath = p.join(imgDir.path, '${DateTime.now().microsecondsSinceEpoch}.jpg');
      final File newImage = await File(pickedFile.path).copy(newPath);

      setState(() {
        _avatarImage = newImage;
      });

      print('Saved avatar to: $newPath');
    }
  }

  Future<void> _saveContact() async {
    if (_formKey.currentState!.validate()) {
      final rawPhone = _phoneController.text.trim();
      final formattedPhone = '+60 $rawPhone';
      final email = _emailController.text.trim();

      final phoneRegex = RegExp(r'^\d{9,10}$');
      final emailRegex = RegExp(r'^\S+@\S+\.\S+$');

      if (!phoneRegex.hasMatch(rawPhone)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid phone number format.')),
        );
        return;
      }

      if (!emailRegex.hasMatch(email)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid email format.')),
        );
        return;
      }

      String avatarRelativePath = '';
      if (_avatarImage != null) {
        final appDir = await getApplicationDocumentsDirectory();
        avatarRelativePath = p.relative(_avatarImage!.path, from: appDir.path);
      }

      final newContact = Contact(
        name: _nameController.text.trim(),
        phone: formattedPhone,
        email: email,
        address: _addressController.text.trim(),
        avatar: avatarRelativePath,
      );

      await DBHelper().insertContact(newContact);
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Contact')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: _avatarImage != null
                      ? FileImage(_avatarImage!)
                      : null,
                  child: _avatarImage == null
                      ? const Icon(Icons.add_a_photo, size: 30)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter name' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone (+60)',
                  hintText: 'e.g. 1127309358',
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter phone number' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'e.g. paul@google.com',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveContact,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}





