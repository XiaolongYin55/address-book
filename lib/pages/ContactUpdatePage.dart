import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
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

    final phoneRaw = widget.contact.phone.startsWith('+60 ')
        ? widget.contact.phone.substring(4)
        : widget.contact.phone;

    phoneController = TextEditingController(text: phoneRaw);
    emailController = TextEditingController(text: widget.contact.email);
    addressController = TextEditingController(text: widget.contact.address);
    avatarController = TextEditingController(text: widget.contact.avatar);

    if (widget.contact.avatar.isNotEmpty) {
      getApplicationDocumentsDirectory().then((appDir) {
        final fullPath = p.join(appDir.path, widget.contact.avatar);
        final file = File(fullPath);
        if (file.existsSync()) {
          setState(() {
            avatarPreview = file;
          });
        }
      });
    }
  }

  Future<void> selectAvatar() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final appDir = await getApplicationDocumentsDirectory();
    final imgDir = Directory(p.join(appDir.path, 'img'));

    if (!await imgDir.exists()) {
      await imgDir.create(recursive: true);
    }

    final fileName = '${DateTime.now().microsecondsSinceEpoch}.jpg';
    final savedImage = await File(pickedFile.path).copy(p.join(imgDir.path, fileName));

    avatarController.text = p.relative(savedImage.path, from: appDir.path);
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
                backgroundImage:
                    avatarPreview != null ? FileImage(avatarPreview!) : null,
                child: avatarPreview == null
                    ? Text(
                        widget.contact.name.isNotEmpty
                            ? widget.contact.name.trim()[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold),
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
                final rawPhone = phoneController.text.trim();
                final formattedPhone = '+60 $rawPhone';
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

                final updatedContact = Contact(
                  id: widget.contact.id,
                  name: nameController.text.trim(),
                  phone: formattedPhone,
                  email: email,
                  address: addressController.text.trim(),
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




