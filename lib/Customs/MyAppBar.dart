import 'package:countdown_event/pages/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import '../pages/home_page.dart';

PreferredSizeWidget getAppBar(
    {required BuildContext context, required String title, TabBar? tabBar}) {
  Color c = Colors.purple;

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>  LoginScreen()), 
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: ${e.toString()}')),
      );
    }
  }

  return AppBar(
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
    centerTitle: true,
    leading: title != "TimeVesta"
        ? IconButton(
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => const HomePage()));
            },
            icon: const Icon(Icons.calendar_month),
            color: c,
          )
        : null,
    actions: [
      IconButton(
        onPressed: () {
          // هنا يمكنك إضافة أي وظيفة شخصية
        },
        icon: const Icon(Icons.person),
        color: c,
      ),
      IconButton(
        onPressed: _logout, // استدعاء دالة تسجيل الخروج عند الضغط على الزر
        icon: const Icon(Icons.logout), // أيقونة تسجيل الخروج
        color: c,
      ),
    ],
    bottom: tabBar,
  );
}
