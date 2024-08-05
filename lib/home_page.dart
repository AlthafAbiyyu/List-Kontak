import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:list_contact_app/contact.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Contact> contacts = List.empty(growable: true);
  List<Contact> filteredContacts = List.empty(growable: true);
  TextEditingController nameController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  int selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final contactsJson = prefs.getString('contacts');
      if (contactsJson != null) {
        final List<dynamic> contactsList = jsonDecode(contactsJson);
        setState(() {
          contacts =
              contactsList.map((json) => Contact.fromJson(json)).toList();
          filteredContacts = contacts;
        });
      } else {
        print('No contacts found in SharedPreferences');
      }
    } catch (e) {
      print('Error loading contacts from SharedPreferences: $e');
    }
  }

  Future<void> _saveContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final String contactsJson =
        jsonEncode(contacts.map((contact) => contact.toJson()).toList());
    await prefs.setString('contacts', contactsJson);
  }

  void _addOrUpdateContact() {
    String name = nameController.text.trim();
    String number = numberController.text.trim();
    if (name.isNotEmpty && number.isNotEmpty) {
      setState(() {
        if (selectedIndex == -1) {
          contacts.add(Contact(name: name, number: number));
        } else {
          contacts[selectedIndex].name = name;
          contacts[selectedIndex].number = number;
          selectedIndex = -1;
        }
        nameController.text = '';
        numberController.text = '';
        filteredContacts = contacts;
      });
      _saveContacts();
    }
  }

  void _deleteContact(int index) {
    setState(() {
      contacts.removeAt(index);
      filteredContacts = contacts;
    });
    _saveContacts();
  }

  void _searchContact(String query) {
    setState(() {
      filteredContacts = contacts
          .where((contact) =>
              contact.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "List Contacts",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search Contact',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (query) => _searchContact(query),
            ),
            const SizedBox(
              height: 15,
            ),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'Contact Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            TextField(
              controller: numberController,
              keyboardType: TextInputType.number,
              maxLength: 12,
              decoration: InputDecoration(
                hintText: 'Contact Number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _addOrUpdateContact,
                  child: const Text('Save'),
                ),
                ElevatedButton(
                  onPressed: _addOrUpdateContact,
                  child: const Text('Update'),
                ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            filteredContacts.isEmpty
                ? const Text(
                    'There is No Contacts Yet',
                    style: TextStyle(fontSize: 20),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: filteredContacts.length,
                      itemBuilder: (context, index) => getRow(index),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget getRow(int index) {
    final random = Random();
    final color = Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      1,
    );

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          foregroundColor: Colors.white,
          child: Text(
            filteredContacts[index].name[0],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              filteredContacts[index].name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              filteredContacts[index].number,
            ),
          ],
        ),
        trailing: SizedBox(
          width: 70,
          child: Row(
            children: [
              InkWell(
                  onTap: () {
                    nameController.text = filteredContacts[index].name;
                    numberController.text = filteredContacts[index].number;
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  child: const Icon(Icons.edit)),
              InkWell(
                  onTap: () => _deleteContact(index),
                  child: const Icon(Icons.delete)),
            ],
          ),
        ),
      ),
    );
  }
}
