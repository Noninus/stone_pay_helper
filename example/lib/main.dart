import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stone_pay_helper/stone_pay_helper.dart';
import 'package:stone_pay_helper_example/payment_test_screen.dart';
import 'package:stone_pay_helper_example/printer_test_screen.dart';

void main() {
  runApp(
    MaterialApp(
      home: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _ec = 'Unknown';
  String _ec2 = "";

  Future<void> initECState() async {
    bool isStone;
    try {
      isStone = await StonePayHelper.isStone;
    } on PlatformException {
      _ec2 = 'Failed to get ec.';
    }

    if (!mounted) return;

    setState(() {
      _ec2 = isStone.toString();
    });
  }

  Future<void> initECState1() async {
    String ec;
    try {
      ec = await StonePayHelper.ec;
    } on PlatformException {
      _ec = 'Failed to get ec.';
    }

    if (!mounted) return;

    setState(() {
      _ec = ec;
    });
  }

  @override
  void initState() {
    initECState();
    initECState1();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            Text('EC: $_ec - $_ec2'),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PaymentTestScreen()));
                },
                child: Text("Ir para Payment")),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PrinterTestScreen()));
                },
                child: Text("Ir para Printer")),
          ],
        ),
      ),
    );
  }
}
