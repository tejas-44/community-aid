import 'package:flutter/material.dart';
import 'pages/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterShare',
      theme: ThemeData(
        primaryColor: Colors.grey[300],
        accentColor: Color(0xff892F2F),
      ),
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}
