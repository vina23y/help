import 'package:flutter/material.dart';
import 'package:help/screens/contacts_helper.dart';
import 'package:help/screens/home_screen.dart';

void main() {
  runApp(
       MaterialApp(
        home: const HomeScreen(),
        routes: <String, WidgetBuilder> {
          '/screen1': (BuildContext context) => const ContactsHelper()
        },
      )
  );
}