import 'package:flutter/material.dart';
import 'package:best/home_page.dart';
import 'package:best/splash_screen.dart';

void main() async {
  runApp(
    new MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Color.fromARGB(255, 2, 112, 247),
        accentColor: Color.fromARGB(255, 2, 112, 247),
        fontFamily: 'Poppins',
      ),
      title: "BEST",
      debugShowCheckedModeBanner: false,
      home: new SplashScreen(),
      routes: <String, WidgetBuilder>{
        '/HomePage': (BuildContext context) => new HomePage()
      },
    ),
  );
  //});
}