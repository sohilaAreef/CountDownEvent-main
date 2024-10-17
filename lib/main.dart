import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';

import 'provider/EventProvider.dart';
import 'provider/DateTimeProvider.dart';
import 'provider/NotesProvider.dart';
import 'pages/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize Awesome Notifications
  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'countdown_channel',
        channelName: 'Countdown Notification',
        channelDescription: 'Notification channel for countdown tests',
        defaultColor: Colors.purple,
        ledColor: Colors.white,
        importance: NotificationImportance.Max,
        playSound: true,
        enableVibration: true,
      )
    ],
    debug: true,
  );

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => EventProvider()),
    ChangeNotifierProvider(create: (_) => DateTimeProvider()),
    ChangeNotifierProvider(create: (_) => NotesProvider()),
  ], child: const CalendarApp()));
}

class CalendarApp extends StatefulWidget {
  const CalendarApp({super.key});

  @override
  _CalendarAppState createState() => _CalendarAppState();
}

class _CalendarAppState extends State<CalendarApp> {
  @override
  void initState() {
    super.initState();
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    eventProvider.fetchEvents();
    requestNotificationPermission();
  }

  Future<void> requestNotificationPermission() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Use LoginScreen as the initial route
      home:  LoginScreen(),
    );
  }
}
