import 'package:flutter/material.dart';
import 'package:list_contact_app/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Contact List',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.cyan),
        home: const HomePage());
  }
}
