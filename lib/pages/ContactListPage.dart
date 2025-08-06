import 'package:flutter/material.dart';
import 'dart:io'; // 用于 FileImage
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
  if (contact.avatar.isNotEmpty) {
    final avatarFile = File(contact.avatar);
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
                return ListTile(
leading: FutureBuilder<bool>(
  future: File(contact.avatar).exists(),
  builder: (context, snapshot) {
    if (snapshot.connectionState != ConnectionState.done) {
      return const CircleAvatar(child: CircularProgressIndicator());
    }

    if (snapshot.data == true) {
      return CircleAvatar(
        backgroundImage: FileImage(File(contact.avatar)),
      );
    } else {
      return CircleAvatar(
        child: Text(
          contact.name.isNotEmpty
              ? contact.name.trim()[0].toUpperCase()
              : '?',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    }
  },
),


                  title: Text(contact.name),
                  subtitle: Text(contact.phone),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ContactUpdatePage(contact: contact),
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
                              content: const Text('Are you sure you want to delete this contact?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
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

