import 'package:flutter/material.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';
import '../../utils/app_textstyles.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final name = TextEditingController(text: 'Shreya Dhaduk');
  final email = TextEditingController(text: 'shreyadhaduk11@gmail.com');
  final number = TextEditingController(text: '9236547895');
  final dob = TextEditingController(text: '21/05/2006');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Profile', style: AppTextStyles.h2), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
          const SizedBox(height: 12),
          CustomTextField(hint: 'Name', controller: name),
          const SizedBox(height: 8),
          CustomTextField(hint: 'Email', controller: email),
          const SizedBox(height: 8),
          CustomTextField(hint: 'Number', controller: number),
          const SizedBox(height: 8),
          CustomTextField(hint: 'Date Of Birth', controller: dob),
          const SizedBox(height: 12),
          CustomButton(label: 'Save Changes', onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved (mock)')))),
        ]),
      ),
    );
  }
}
