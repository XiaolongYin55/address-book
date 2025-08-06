import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ios_app/services/db_helper.dart';
import 'package:flutter_ios_app/models/contact.dart';

void main() {
  final db = DBHelper();

  test('Add a new contact', () async {
    Contact contact = Contact(
      name: 'Paul',
      phone: '1234567890',
      email: 'john@example.com',
      address: '123 Street',
      avatar: 'https://i.pravatar.cc/150?img=1',
    );
    await db.insertContact(contact);

    final contacts = await db.getContacts();
    expect(contacts.any((c) => c.name == 'John Doe'), true);
  });

  test('Update a contact', () async {
    final contacts = await db.getContacts();
    if (contacts.isNotEmpty) {
      final contact = contacts.first;
      contact.name = 'Updated Name';
      await db.updateContact(contact);

      final updated = await db.getContacts();
      expect(updated.first.name, 'Updated Name');
    }
  });

  test('Delete a contact', () async {
    final contacts = await db.getContacts();
    if (contacts.isNotEmpty) {
      await db.deleteContact(contacts.first.id!);
      final afterDelete = await db.getContacts();
      expect(afterDelete.length, contacts.length - 1);
    }
  });
}
