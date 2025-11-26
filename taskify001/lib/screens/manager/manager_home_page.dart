import 'package:flutter/material.dart';

// Import your pages here
import 'add_member_page.dart';
import 'team_members_page.dart';
import 'pending_tasks_page.dart';
import 'assign_task_page.dart';
import 'manager_profile_page.dart';
import 'package:flutter/material.dart';

class ManagerHomePage extends StatefulWidget {
  const ManagerHomePage({super.key});

  @override
  State<ManagerHomePage> createState() => _ManagerHomePageState();
}

class _ManagerHomePageState extends State<ManagerHomePage> {
  int _currentIndex = 0;

  void navigateToTeamMembers() {
    setState(() => _currentIndex = 1); // go to Team Members tab
  }

  late final List<Widget> _pages = [
    // AddMemberPage is not const because it accepts a callback
    AddMemberPage(onMemberAdded: navigateToTeamMembers),
    const TeamMembersPage(),
    const PendingTasksPage(),
    const AssignTaskPage(),
    const ManagerProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack preserves each page's state (e.g. scroll position, form data)
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add_alt_1),
            label: "Add Member",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: "Team",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pending_actions),
            label: "Pending Tasks",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_add),
            label: "Assign Task",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}