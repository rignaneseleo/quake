import 'package:flutter/material.dart';
import 'package:quake/views/dashboard.dart';
import 'package:vibration/vibration.dart';

class LandingPage extends StatefulWidget {
  static const String id = 'landing_page';

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 1500), () {
      Navigator.popAndPushNamed(context, Dashboard.id);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFF101010),
        child: Center(
          child: Text("Music to Vibration"),
        ),
      ),
    );
  }
}
