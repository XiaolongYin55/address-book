import 'dart:io';
import 'package:flutter/material.dart';
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
      // ✅ 第 1 段：保存图片到本地持久目录
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = DateTime.now().microsecondsSinceEpoch.toString() + '.jpg';
      final savedImage = await File(pickedFile.path).copy('${appDir.path}/$fileName');

      // ✅ 第 2 段：将路径写入表单控制器
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
                backgroundImage: avatarPreview != null
                    ? FileImage(avatarPreview!)
                    : null,
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
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone')),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Address')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // ✅ 第 3 段：创建联系人并插入数据库
                final contact = Contact(
                  name: nameController.text,
                  phone: phoneController.text,
                  email: emailController.text,
                  address: addressController.text,
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



