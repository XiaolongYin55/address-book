import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/contact.dart';
import '../services/db_helper.dart';

class ContactUpdatePage extends StatefulWidget {
  final Contact contact;

  const ContactUpdatePage({super.key, required this.contact});

  @override
  State<ContactUpdatePage> createState() => _ContactUpdatePageState();
}

class _ContactUpdatePageState extends State<ContactUpdatePage> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late TextEditingController addressController;
  late TextEditingController avatarController;

  File? avatarPreview;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.contact.name);
    phoneController = TextEditingController(text: widget.contact.phone);
    emailController = TextEditingController(text: widget.contact.email);
    addressController = TextEditingController(text: widget.contact.address);
    avatarController = TextEditingController(text: widget.contact.avatar);

    if (widget.contact.avatar.isNotEmpty) {
      avatarPreview = File(widget.contact.avatar);
    }
  }

  Future<void> selectAvatar() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final appDir = await getApplicationDocumentsDirectory();
    final fileName = DateTime.now().microsecondsSinceEpoch.toString() + '.jpg';
    final savedImage = await File(pickedFile.path).copy('${appDir.path}/$fileName');

    avatarController.text = savedImage.path;
    setState(() {
      avatarPreview = savedImage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update Contact')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: avatarPreview != null
                    ? FileImage(avatarPreview!)
                    : null,
                child: avatarPreview == null
                    ? Text(
                        widget.contact.name.isNotEmpty
                            ? widget.contact.name.trim()[0].toUpperCase()
                            : '?',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: selectAvatar,
              child: const Text('Change Avatar'),
            ),
            const SizedBox(height: 20),
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone')),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Address')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final updatedContact = Contact(
                  id: widget.contact.id,
                  name: nameController.text,
                  phone: phoneController.text,
                  email: emailController.text,
                  address: addressController.text,
                  avatar: avatarController.text,
                );

                await DBHelper().updateContact(updatedContact);
                Navigator.pop(context, true);
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}


