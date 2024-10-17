import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../pages/EventScreen.dart';
import '../pages/NotesViewBody.dart';
import '../widgets/Add_widget.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int selectedIdx = 1;
  int changeIdx = 0;

  @override
  void initState() {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
    super.initState();
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      // إعادة توجيه المستخدم إلى شاشة تسجيل الدخول
      Navigator.pushReplacementNamed(context, '/login'); // تأكد من تعديل المسار حسب الشاشة المناسبة
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> screens = [
      const EventScreen(),
      const AddWidget(),
      const NotesViewBody(),
    ];

    return Scaffold(
      body: screens[changeIdx],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.black,
        buttonBackgroundColor: Colors.purple,
        color: Colors.blueGrey,
        height: 60,
        index: 1,
        onTap: (value) {
          setState(() {
            if (value == 1) {
              showModalBottomSheet(
                context: context,
                builder: (context) => const AddWidget(),
              );
            } else {
              changeIdx = value;
            }
          });
        },
        items: [
          _buildNavIcons(Icons.event, "Events", selectedIdx == 0),
          _buildNavIcons(Icons.add, "Add", selectedIdx == 1),
          _buildNavIcons(Icons.checklist, "Todo", selectedIdx == 2),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _logout(context); // استدعاء دالة تسجيل الخروج عند الضغط على الزر
        },
        child: const Icon(Icons.logout), // أيقونة تسجيل الخروج
        backgroundColor: Colors.red, // يمكنك تغيير اللون كما ترغب
      ),
    );
  }
}

Widget _buildNavIcons(IconData icon, String label, bool isSelected) {
  Color c = Colors.grey[400]!;

  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: c,
          size: isSelected ? 30 : 24,
        ),
        const SizedBox(height: 4),
        if (!isSelected)
          Text(
            label,
            style: TextStyle(
              color: c,
              fontSize: 12,
            ),
          ),
      ],
    ),
  );
}
