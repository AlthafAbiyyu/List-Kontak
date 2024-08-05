class Contact {
  String name;
  String number;

  Contact({required this.name, required this.number});

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      name: json['name'],
      number: json['number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'number': number,
    };
  }
}
