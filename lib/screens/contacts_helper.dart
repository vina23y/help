  import 'package:flutter/material.dart';
  import 'package:permission_handler/permission_handler.dart';
  import 'package:contacts_service/contacts_service.dart';
  import 'package:shared_preferences/shared_preferences.dart';
  import 'package:flutter_local_notifications/flutter_local_notifications.dart';
  import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

  class ContactsHelper extends StatefulWidget {
    const ContactsHelper({Key? key}) : super(key: key);

    @override
    _ContactsHelperState createState() => _ContactsHelperState();
  }

  class _ContactsHelperState extends State<ContactsHelper> {
    Contact? selectedContact;
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    @override
    void initState() {
      super.initState();
      initializeNotifications();
      loadContactFromSharedPreferences().then((contact) {
        setState(() {
          selectedContact = contact;
        });
      });
    }

    Future<Contact> loadContactFromSharedPreferences() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? cName = prefs.getString('C_name');
      String? cMobile = prefs.getString('C_mobile');
      if (cName != null && cMobile != null) {
        return Contact(
          displayName: cName,
          phones: [Item(label: 'mobile', value: cMobile)],
        );
      }
      return Contact();
    }

    Future<void> initializeNotifications() async {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('mipmap/ic_launcher');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    }

    Future<void> updateNotification(String contactMobile) async {
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
        payload: contactMobile,
      );
    }

    Future<void> importContact(BuildContext context) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      PermissionStatus permissionStatus = await Permission.contacts.request();
      if (permissionStatus.isGranted) {
        Contact? contact = await ContactsService.openDeviceContactPicker();
        if (contact != null) {
          setState(() {
            selectedContact = contact;
          });

          await prefs.setString('C_name', selectedContact!.displayName ?? '');
          await prefs.setString(
              'C_mobile', selectedContact!.phones!.first.value ?? '');

          String contactMobile = selectedContact!.phones!.first.value ?? '';
          await updateNotification(contactMobile);

        }
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: const Text("Please grant permission to access contacts."),
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
      return Scaffold(
        appBar: AppBar(
          title: const Text('Emergency Details'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Selected Contact:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.person),
                title: Text(selectedContact?.displayName ?? 'Select an emergency contact'),
                onTap: () {
                  importContact(context);
                },
              ),
          /*    ElevatedButton(onPressed: (){
                Navigator.pop(context);
              }, child: Text("Save Data"),)*/
            ],
          ),
        ),
      );
    }
  }
