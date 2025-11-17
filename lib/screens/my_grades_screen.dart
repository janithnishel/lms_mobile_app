import 'package:flutter/material.dart';

class MyGradesScreen extends StatelessWidget {
  const MyGradesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Grades'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: const Center(child: Text('My Grades Screen')),
    );
  }
}
