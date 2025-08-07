import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../models/contact.dart';
import '../services/db_helper.dart';
import 'ContactInsertPage.dart';
import 'ContactUpdatePage.dart';

class ContactListPage extends StatefulWidget {
  const ContactListPage({super.key});

  @override
  State<ContactListPage> createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  List<Contact> contacts = [];

  @override
  void initState() {
    super.initState();
    fetchContacts();
  }

  Future<void> fetchContacts() async {
    final data = await DBHelper().getContacts();
    for (var c in data) {
      print('Loaded contact: ${c.name}, avatar: ${c.avatar}');
    }
    setState(() {
      contacts = data;
    });
  }

  Future<void> deleteContact(int id) async {
    final contact = contacts.firstWhere((c) => c.id == id);
    final appDir = await getApplicationDocumentsDirectory();
    final avatarPath = p.join(appDir.path, contact.avatar);

    if (contact.avatar.isNotEmpty) {
      final avatarFile = File(avatarPath);
      if (await avatarFile.exists()) {
        await avatarFile.delete();
      }
    }

    await DBHelper().deleteContact(id);
    fetchContacts();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contact deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact List')),
      body: contacts.isEmpty
          ? const Center(child: Text('No contacts found'))
          : ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                return FutureBuilder<Directory>(
                  future: getApplicationDocumentsDirectory(),
                  builder: (context, snapshot) {
                    Widget avatarWidget;
                    if (!snapshot.hasData) {
                      avatarWidget = const CircleAvatar(
                          child: CircularProgressIndicator());
                    } else {
                      final fullPath =
                          File(p.join(snapshot.data!.path, contact.avatar));
                      avatarWidget = fullPath.existsSync()
                          ? CircleAvatar(backgroundImage: FileImage(fullPath))
                          : CircleAvatar(
                              child: Text(
                                contact.name.isNotEmpty
                                    ? contact.name.trim()[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            );
                    }

                    return ListTile(
                      leading: SizedBox(
                        width: 70, 
                        height: 70, 
                        child: avatarWidget,
                      ),
                      title: Text(contact.name),
                      subtitle: Text('${contact.phone}\n${contact.email}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ContactUpdatePage(contact: contact),
                                ),
                              );
                              if (result == true) fetchContacts();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Contact'),
                                  content: const Text(
                                      'Are you sure you want to delete this contact?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Delete',
                                          style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await deleteContact(contact.id!);
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ContactInsertPage()),
          );
          if (result == true) fetchContacts();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
