import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Joke App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final NotificationManager _notificationManager = NotificationManager();

  @override
  void initState() {
    super.initState();
    _notificationManager.initialize();
  }

  @override
  void dispose() {
    _notificationManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Joke App')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _notificationManager.showDelayedNotification(),
              child: const Text('Show Delayed Notification'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _notificationManager.showImmediateNotification(),
              child: const Text('Show Immediate Notification'),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationManager {
  late FlutterLocalNotificationsPlugin _notificationsPlugin;
  bool _isInitialized = false;

  NotificationManager() {
    _notificationsPlugin = FlutterLocalNotificationsPlugin();
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    if (Platform.isAndroid) {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('ic_dialog_info');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);
      await _notificationsPlugin.initialize(initializationSettings);

      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        '200022',
        'Joke Channel',
        description: 'Channel for joke notifications',
        importance: Importance.high,
      );
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    } else if (Platform.isWindows) {
      const WindowsInitializationSettings initializationSettingsWindows =
          WindowsInitializationSettings(
        appName: 'JokeApp',
        appUserModelId: 'com.example.jokeapp',
        guid: '550e8400-e29b-41d4-a716-446655440000',
      );
      const InitializationSettings initializationSettings =
          InitializationSettings(windows: initializationSettingsWindows);
      await _notificationsPlugin.initialize(initializationSettings);
    }

    _isInitialized = true;
  }

  void dispose() {
    _notificationsPlugin.cancelAll();
  }

  Future<void> showDelayedNotification() async {
    if (!_isInitialized) {
      print('Notification manager not initialized');
      return;
    }

    const int delaySeconds = 9;
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      '200022',
      'Joke Channel',
      importance: Importance.high,
      priority: Priority.high,
      vibrationPattern: Int64List.fromList(const [0, 1000]),
      autoCancel: true,
    );
    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );
  

    Timer(Duration(seconds: delaySeconds), () async {
      await _notificationsPlugin.show(
        5453,
        'What is the secret of comedy?',
        'Картун Я.С. 75МС',
        notificationDetails,
      );
      print('Delayed notification shown');
    });
  }

  Future<void> showImmediateNotification() async {
    if (!_isInitialized) {
      print('Notification manager not initialized');
      return;
    }

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      '200022',
      'Joke Channel',
      importance: Importance.high,
      priority: Priority.high,
      vibrationPattern: Int64List.fromList(const [0, 1000]),
      autoCancel: true,
    );
    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      5454,
      'What is the secret of comedy?',
      'Заноздра Д.Р. 75МС',
      notificationDetails,
    );
    print('Immediate notification shown');
  }
}
