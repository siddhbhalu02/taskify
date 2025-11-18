import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskify001/models/user_role.dart';
import '../../providers/user_provider.dart';
import '../../providers/team_provider.dart';

class TeamMembersPage extends StatefulWidget {
  const TeamMembersPage({super.key});

  @override
  State<TeamMembersPage> createState() => _TeamMembersPageState();
}

class _TeamMembersPageState extends State<TeamMembersPage> {
  @override
  void initState() {
    super.initState();

    final manager = Provider.of<UserProvider>(context, listen: false).currentUser;

    if (manager != null) {
      Provider.of<TeamProvider>(context, listen: false)
          .fetchTeamMembers(manager.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final teamProvider = Provider.of<TeamProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Team Members")),

      body: teamProvider.loading
          ? const Center(child: CircularProgressIndicator())
          : teamProvider.teamMembers.isEmpty
          ? const Center(child: Text("No team members added yet"))
          : ListView.builder(
        itemCount: teamProvider.teamMembers.length,
        itemBuilder: (context, index) {
          final member = teamProvider.teamMembers[index];

          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(member.name),
            subtitle: Text(member.email),
            trailing: Text(member.role.value),
          );
        },
      ),
    );
  }
}
