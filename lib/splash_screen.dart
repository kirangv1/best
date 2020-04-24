import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

const _LOGO_SIZE = 140.0;

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Timer(Duration(milliseconds: 4500), () {
      Navigator.pushReplacementNamed(context, '/HomePage');
    });

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height/1.3,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromARGB(255, 18, 82, 175),
                      Color.fromARGB(255, 2, 112, 247)
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(190)
                  )
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Spacer(),
                  Align(
                    alignment: Alignment.center,
                    child: Image.asset("assets/img/conference.png", width: 130, fit: BoxFit.contain),
                  ),
                  //Spacer(),

                  Text(
                    "BEL e-Sammelan Tool",
                    style: TextStyle(fontFamily: "Righteous", fontSize: 25.0, color: Color.fromARGB(255, 255, 255, 255), fontWeight: FontWeight.w900),
                  ),
                  Text(
                    "(A Video Conferencing Tool)",
                    style: TextStyle(fontFamily: "WorkSansRegular", fontSize: 15.0, color: Color.fromARGB(255, 255, 255, 255)),
                  ),
                  Text(
                    "Version 1.0.0",
                    style: TextStyle(fontFamily: "WorkSansRegular", fontSize: 12.0, color: Color.fromARGB(255, 255, 255, 255)),
                  ),
                  Spacer(),
                ],
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 90,
                ),
                child: Image.asset("assets/img/bel_logo.png", width: 130, fit: BoxFit.contain),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
