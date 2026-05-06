import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  String appBarName = 'وصفة اليوم';
  Color orange = Colors.orange;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: Image.asset('assets/logo.png'),
          leadingWidth: 100,
          elevation: 0,
          backgroundColor: Colors.white,
        ),
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BackInLeft(
                curve: Curves.bounceIn,
                duration: Duration(seconds: 3),
                child: Image.asset('assets/logo.png', width: 200),
              ),
              Text('CADRINGF', style: TextStyle(fontSize: 40)),
            ],
          ),
        ),
      ),
    );
  }
}
