class Contact {
  String name;
  String phone;
  String email;
  String address;
  String avatar;
  int? id;

  Contact({
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.avatar,
    this.id,
  });

  // factory constructor for JSON
  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      email: map['email'],
      address: map['address'],
      avatar: map['avatar'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'avatar': avatar,
    };
  }
}
