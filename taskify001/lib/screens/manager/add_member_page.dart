import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/add_member_controller.dart';
import '../../providers/user_provider.dart';
import '../../services/add_member_service.dart';
import '../../widgets/custom_button.dart';
import '../../utils/app_textstyles.dart';

class AddMemberPage extends StatefulWidget {
  const AddMemberPage({super.key});

  @override
  State<AddMemberPage> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberPage> {
  final controller = AddMemberController();
  bool loading = false;

  void handleAddMember() async {
    if (!controller.formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final manager = Provider.of<UserProvider>(context, listen: false).currentUser;

      await AddMemberService().addMember(
        name: controller.name.text.trim(),
        email: controller.email.text.trim(),
        password: controller.password.text.trim(),
        managerId: manager!.id, // manager UID
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Team member added successfully!")),
      );

      Navigator.pop(context); // return to manager page

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Team Member", style: AppTextStyles.h2),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 20),
              Text("Enter Member Details", style: AppTextStyles.h1),

              const SizedBox(height: 20),

              TextFormField(
                controller: controller.name,
                decoration: const InputDecoration(
                  hintText: "Full Name",
                  border: OutlineInputBorder(),
                ),
                validator: controller.validateName,
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: controller.email,
                decoration: const InputDecoration(
                  hintText: "Email Address",
                  border: OutlineInputBorder(),
                ),
                validator: controller.validateEmail,
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: controller.password,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: "Password",
                  border: OutlineInputBorder(),
                ),
                validator: controller.validatePassword,
              ),

              const SizedBox(height: 18),

              CustomButton(
                label: loading ? "Adding..." : "Add Member",
                onPressed: loading ? null : handleAddMember,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
