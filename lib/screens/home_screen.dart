import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:help/screens/contacts_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
 {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  late String contactMobile;

  @override
  void initState() {

    super.initState();
    initializeNotifications();
    updateNotification();
  }

findContacts()
{
    
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context)=>const ContactsHelper()));

  
      updateNotification();
     
  }


  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> updateNotification() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('C_mobile') != null) {
      contactMobile = prefs.getString('C_mobile')!;
      showNotification(contactMobile);
    } else {
      contactMobile = "0";
    }
  }

  Future<void> showNotification(String contactMobile) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'channel_id',
      'Channel Name',
      importance: Importance.max,
      priority: Priority.high,
      ongoing: true,
      autoCancel: false,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'In case of emergency, tap this notification or call',
      contactMobile,
      platformChannelSpecifics,
    );
  }

  Future<void> callData() async {
    if (contactMobile != "0") {
      await FlutterPhoneDirectCaller.callNumber(contactMobile);
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: const Text("Fill emergency details using the Settings icon at top right part of screen"),
            actions: <Widget>[
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return 
     Scaffold(
      appBar: AppBar(
        title: const Text('Contact Picker'),
        backgroundColor: Colors.red,
        actions: <Widget>[
    Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: GestureDetector(
        onTap: () {
          findContacts();
        },
        child: const Icon(
          Icons.settings,
          size: 26.0,
        ),
      )
    ),
    
  ],
       ),
      body: 
      Container(
      
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade900,
          shape: const CircleBorder(),
        ),
        onPressed: callData,
        child: const Text(
          "Press To Call",
          style: TextStyle(
            color: Colors.white,
            fontSize: 72.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    )
     )
     ;
     
  }
}







